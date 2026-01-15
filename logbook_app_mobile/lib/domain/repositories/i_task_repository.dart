// lib/domain/repositories/i_task_repository.dart

import '../entities/task_entity.dart';

abstract class ITaskRepository {
  /// Get daily tasks for a season
  Future<List<TaskEntity>> getDailyTasks(String seasonId, DateTime date);

  /// Log task confirmation (complete/skip)
  Future<bool> logTaskConfirmation({
    required String seasonId,
    required String taskName,
    required String status,
    String? logType,
    List<Map<String, dynamic>>? usedMaterials,
    String? notes,
    String? location,
    DateTime? completedAt,
  });

  /// Get manual logs
  Future<List<Map<String, dynamic>>> getManualLogs(String seasonId);
}
