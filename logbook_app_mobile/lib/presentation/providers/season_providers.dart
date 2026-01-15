// lib/presentation/providers/season_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/season_remote_datasource.dart';
import '../../data/repositories/season_repository_impl.dart';
import '../../domain/repositories/i_season_repository.dart';
import '../../domain/usecases/season/get_seasons_usecase.dart';
import '../../domain/usecases/season/create_season_usecase.dart';
import '../../domain/usecases/season/delete_season_usecase.dart';

// ==================== Data Source ====================
final seasonRemoteDataSourceProvider = Provider<SeasonRemoteDataSource>((ref) {
  return SeasonRemoteDataSource(apiClient: ApiClient.instance);
});

// ==================== Repository ====================
final seasonRepositoryProvider = Provider<ISeasonRepository>((ref) {
  final dataSource = ref.read(seasonRemoteDataSourceProvider);
  return SeasonRepositoryImpl(remoteDataSource: dataSource);
});

// ==================== Use Cases ====================
final getSeasonsUseCaseProvider = Provider<GetSeasonsUseCase>((ref) {
  final repository = ref.read(seasonRepositoryProvider);
  return GetSeasonsUseCase(repository);
});

final createSeasonUseCaseProvider = Provider<CreateSeasonUseCase>((ref) {
  final repository = ref.read(seasonRepositoryProvider);
  return CreateSeasonUseCase(repository);
});

final deleteSeasonUseCaseProvider = Provider<DeleteSeasonUseCase>((ref) {
  final repository = ref.read(seasonRepositoryProvider);
  return DeleteSeasonUseCase(repository);
});
