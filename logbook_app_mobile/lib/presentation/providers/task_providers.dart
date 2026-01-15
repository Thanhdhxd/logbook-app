// lib/presentation/providers/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../domain/usecases/task/get_daily_tasks_usecase.dart';
import '../../domain/usecases/task/log_task_usecase.dart';

// ==================== Data Source ====================
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(apiClient: ApiClient.instance);
});

// ==================== Repository ====================
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dataSource = ref.read(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource: dataSource);
});

// ==================== Use Cases ====================
final getDailyTasksUseCaseProvider = Provider<GetDailyTasksUseCase>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return GetDailyTasksUseCase(repository);
});

final logTaskUseCaseProvider = Provider<LogTaskUseCase>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return LogTaskUseCase(repository);
});
