// lib/presentation/providers/traceability_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/traceability_remote_datasource.dart';
import '../../data/repositories/traceability_repository_impl.dart';
import '../../domain/repositories/i_traceability_repository.dart';
import '../../domain/usecases/traceability/get_traceability_usecase.dart';
import 'app_providers.dart';

// DataSource Provider
final traceabilityDataSourceProvider = Provider<TraceabilityRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TraceabilityRemoteDataSource(apiClient);
});

// Repository Provider
final traceabilityRepositoryProvider = Provider<ITraceabilityRepository>((ref) {
  final dataSource = ref.watch(traceabilityDataSourceProvider);
  return TraceabilityRepositoryImpl(dataSource);
});

// Use Case Provider
final getTraceabilityUseCaseProvider = Provider<GetTraceabilityUseCase>((ref) {
  final repository = ref.watch(traceabilityRepositoryProvider);
  return GetTraceabilityUseCase(repository);
});
