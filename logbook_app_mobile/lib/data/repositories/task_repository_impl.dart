// lib/data/repositories/task_repository_impl.dart

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../core/network/app_logger.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final _logger = AppLogger.instance;

  TaskRepositoryImpl({required TaskRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TaskEntity>> getDailyTasks(String seasonId, DateTime date) async {
    try {
      final dtos = await _remoteDataSource.getDailyTasks(seasonId, date);
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      _logger.error('TaskRepository: Failed to get daily tasks', e);
      rethrow;
    }
  }

  @override
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
    try {
      return await _remoteDataSource.logTaskConfirmation(
        seasonId: seasonId,
        taskName: taskName,
        status: status,
        logType: logType,
        usedMaterials: usedMaterials,
        notes: notes,
        location: location,
        completedAt: completedAt,
      );
    } catch (e) {
      _logger.error('TaskRepository: Failed to log task', e);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getManualLogs(String seasonId) async {
    try {
      return await _remoteDataSource.getManualLogs(seasonId);
    } catch (e) {
      _logger.error('TaskRepository: Failed to get manual logs', e);
      rethrow;
    }
  }
}
