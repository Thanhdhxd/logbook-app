// lib/presentation/services/task_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/task_entity.dart';

class TaskService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Lấy danh sách công việc hàng ngày cho một mùa vụ
  Future<Map<String, dynamic>> getDailyTasks(String seasonId) async {
    try {
      _logger.debug('Fetching daily tasks for season: $seasonId');

      final response = await _apiClient.get('/seasons/daily/$seasonId');
      
      // Xử lý response format từ backend
      final responseData = response['data'] ?? response;
      final List<dynamic>? tasksJson = responseData['tasks'];
      
      final result = {
        'currentDay': responseData['currentDay'],
        'currentStage': responseData['currentStage'],
        'farmArea': responseData['farmArea'],
        'tasks': (tasksJson ?? []).map((json) => TaskEntity(
          taskId: json['_id'] ?? json['taskId'] ?? '',
          taskName: json['taskName'] ?? '',
          frequency: json['frequency'] ?? '',
          suggestedMaterials: (json['suggestedMaterials'] as List?)
              ?.map((m) => SuggestedMaterialEntity(
                    materialName: m['materialName'] ?? '',
                    quantityPerUnit: (m['quantityPerUnit'] ?? 0).toDouble(),
                    unit: m['unit'] ?? '',
                  ))
              .toList() ?? [],
          usedMaterials: (json['usedMaterials'] as List?)
              ?.map((m) => UsedMaterialEntity(
                    materialName: m['materialName'] ?? '',
                    quantity: (m['quantity'] ?? 0).toDouble(),
                    unit: m['unit'] ?? '',
                  ))
              .toList() ?? [],
          area: json['area'],
          status: json['status'],
          notes: json['notes'],
          completedAt: json['completedAt'] != null 
              ? DateTime.parse(json['completedAt']) 
              : null,
        )).toList(),
      };
      
      _logger.info('Loaded ${result['tasks'].length} tasks for season');
      return result;
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw const ServerException('Không tìm thấy mùa vụ hoặc kế hoạch', statusCode: 404);
      }
      rethrow;
    } catch (e) {
      _logger.error('Failed to load daily tasks', e);
      rethrow;
    }
  }

  // Ghi nhật ký công việc
  Future<bool> logTaskConfirmation({
    required String seasonId,
    required String taskName,
    required String status, // DONE, SKIPPED
    List<Map<String, dynamic>>? usedMaterials,
    String? notes,
    String logType = 'scheduled', // scheduled hoặc manual
    String? location,
    DateTime? completedAt,
  }) async {
    try {
      _logger.info('Logging task confirmation: $taskName ($status)');

      final body = {
        'season': seasonId,
        'taskName': taskName,
        'status': status,
        'logType': logType,
        'usedMaterials': usedMaterials ?? [],
        'notes': notes,
        if (location != null) 'location': location,
        if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
      };
      
      await _apiClient.post('/logbook', data: body);
      _logger.info('Task logged successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to log task', e);
      return false;
    }
  }

  // Ẩn task vĩnh viễn (bỏ qua hoặc hoàn thành)
  Future<bool> hideTask({
    required String seasonId,
    required String taskName,
  }) async {
    try {
      _logger.info('Hiding task: $taskName');

      await _apiClient.post('/logbook/hide', data: {
        'season': seasonId,
        'taskName': taskName,
      });
      
      _logger.info('Task hidden successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to hide task', e);
      return false;
    }
  }

  // Lấy nhật ký thủ công của một mùa vụ
  Future<List<TaskEntity>> getManualLogs(String seasonId) async {
    try {
      _logger.debug('Fetching manual logs for season: $seasonId');

      final response = await _apiClient.get('/logbook/season/$seasonId');
      
      // Xử lý response format từ backend
      final responseData = response['data'] ?? response;
      final List<dynamic>? logsJson = responseData['logs'];
      
      if (logsJson == null || logsJson.isEmpty) {
        _logger.debug('No manual logs found');
        return [];
      }
      
      final logs = logsJson.map((json) => TaskEntity(
        taskId: json['_id'] ?? '',
        taskName: json['taskName'] ?? '',
        frequency: 'manual',
        suggestedMaterials: [],
        usedMaterials: (json['usedMaterials'] as List?)
            ?.map((m) => UsedMaterialEntity(
                  materialName: m['materialName'] ?? '',
                  quantity: (m['quantity'] ?? 0).toDouble(),
                  unit: m['unit'] ?? '',
                ))
            .toList() ?? [],
        area: null,
        status: json['status'] ?? 'DONE',
        notes: json['notes'],
        completedAt: json['logDate'] != null 
            ? DateTime.parse(json['logDate']) 
            : null,
      )).toList();
      
      _logger.info('Loaded ${logs.length} manual logs');
      return logs;
    } catch (e) {
      _logger.error('Failed to load manual logs', e);
      rethrow;
    }
  }
}