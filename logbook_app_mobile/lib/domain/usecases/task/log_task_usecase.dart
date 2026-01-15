// lib/domain/usecases/task/log_task_usecase.dart

import '../../repositories/i_task_repository.dart';

class LogTaskUseCase {
  final ITaskRepository _repository;

  LogTaskUseCase(this._repository);

  Future<bool> execute({
    required String seasonId,
    required String taskName,
    required String status,
    String? logType,
    List<Map<String, dynamic>>? usedMaterials,
    String? notes,
    String? location,
    DateTime? completedAt,
  }) async {
    if (seasonId.isEmpty || taskName.isEmpty) {
      throw ArgumentError('Season ID and task name cannot be empty');
    }

    return await _repository.logTaskConfirmation(
      seasonId: seasonId,
      taskName: taskName,
      status: status,
      logType: logType,
      usedMaterials: usedMaterials,
      notes: notes,
      location: location,
      completedAt: completedAt,
    );
  }
}
