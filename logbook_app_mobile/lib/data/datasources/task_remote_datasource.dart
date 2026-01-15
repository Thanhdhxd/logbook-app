// lib/data/datasources/task_remote_datasource.dart

import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../data/models/task_dto.dart';

class TaskRemoteDataSource {
  final ApiClient _apiClient;
  final _logger = AppLogger.instance;

  TaskRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<TaskDTO>> getDailyTasks(String seasonId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    _logger.info('TaskDataSource: Fetching tasks for $seasonId on $dateStr');

    // Backend route: GET /seasons/daily/:seasonId
    final response = await _apiClient.get(
      '/seasons/daily/$seasonId',
      queryParameters: {'date': dateStr},
    );

    // Backend response: { data: { currentDay, currentStage, farmArea, tasks: [...] } }
    final responseData = response['data'];
    final List<dynamic> tasksData = responseData?['tasks'] ?? [];
    return tasksData.map((json) => TaskDTO.fromJson(json)).toList();
  }

  Future<bool> logTaskConfirmation({
    required String seasonId,
    required String taskName,
    required String status,
    String? logType,
    List<Map<String, dynamic>>? usedMaterials,
    String? notes,
    String? location,
    DateTime? completedAt,
  }) async {
    _logger.info('TaskDataSource: Logging task $taskName as $status');

    final data = {
      'taskName': taskName,
      'status': status,
      if (logType != null) 'logType': logType,
      if (usedMaterials != null) 'usedMaterials': usedMaterials,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
    };

    final response = await _apiClient.post(
      '/seasons/$seasonId/logs',
      data: data,
    );

    return response['success'] == true;
  }

  Future<List<Map<String, dynamic>>> getManualLogs(String seasonId) async {
    final response = await _apiClient.get('/seasons/$seasonId/manual-logs');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
}
