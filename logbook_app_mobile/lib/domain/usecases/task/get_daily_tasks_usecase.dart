// lib/domain/usecases/task/get_daily_tasks_usecase.dart

import '../../entities/task_entity.dart';
import '../../repositories/i_task_repository.dart';

class GetDailyTasksUseCase {
  final ITaskRepository _repository;

  GetDailyTasksUseCase(this._repository);

  Future<List<TaskEntity>> execute(String seasonId, DateTime date) async {
    if (seasonId.isEmpty) {
      throw ArgumentError('Season ID cannot be empty');
    }
    return await _repository.getDailyTasks(seasonId, date);
  }
}
