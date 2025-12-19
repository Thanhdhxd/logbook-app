// lib/services/task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/daily_task.dart';

class TaskService {
  // Lấy danh sách công việc hàng ngày cho một mùa vụ
  Future<Map<String, dynamic>> getDailyTasks(String seasonId) async {
    final url = Uri.parse('${AppConstants.seasonsUrl}/daily/$seasonId');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Xử lý response format mới từ backend (có success và data wrapper)
        final responseData = data['data'] ?? data;
        final List<dynamic>? tasksJson = responseData['tasks'];
        
        return {
          'currentDay': responseData['currentDay'],
          'currentStage': responseData['currentStage'],
          'farmArea': responseData['farmArea'],
          'tasks': (tasksJson ?? []).map((json) => DailyTask.fromJson(json)).toList(),
        };
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mùa vụ hoặc kế hoạch');
      } else {
        throw Exception('Lỗi khi tải công việc: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
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
    final url = Uri.parse(AppConstants.logbookUrl);
    
    try {
      final body = {
        'season': seasonId,
        'taskName': taskName,
        'status': status,
        'logType': logType,
        'usedMaterials': usedMaterials ?? [],
        'notes': notes,
      };
      
      // Thêm location và completedAt nếu có
      if (location != null) {
        body['location'] = location;
      }
      if (completedAt != null) {
        body['completedAt'] = completedAt.toIso8601String();
      }
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Ẩn task vĩnh viễn (bỏ qua hoặc hoàn thành)
  Future<bool> hideTask({
    required String seasonId,
    required String taskName,
    required String reason, // DONE hoặc SKIPPED
  }) async {
    final url = Uri.parse('${AppConstants.seasonsUrl}/hide-task');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'seasonId': seasonId,
          'taskName': taskName,
          'reason': reason,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Lấy nhật ký thủ công của một mùa vụ
  Future<List<DailyTask>> getManualLogs(String seasonId) async {
    final url = Uri.parse('${AppConstants.logbookUrl}/season/$seasonId');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Xử lý response format mới từ backend (có success và data wrapper)
        final responseData = data['data'] ?? data;
        final List<dynamic>? logsJson = responseData['logs'];
        
        if (logsJson == null || logsJson.isEmpty) {
          return [];
        }
        
        return logsJson.map((json) => DailyTask(
          taskId: json['_id'] ?? '',
          taskName: json['taskName'] ?? '',
          frequency: 'manual',
          suggestedMaterials: [],
          usedMaterials: (json['usedMaterials'] as List?)
              ?.map((m) => UsedMaterial(
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
      } else {
        throw Exception('Lỗi khi tải nhật ký: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}