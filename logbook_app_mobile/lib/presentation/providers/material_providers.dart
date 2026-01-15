// lib/presentation/providers/material_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/material_remote_datasource.dart';
import '../../data/repositories/material_repository_impl.dart';
import '../../domain/repositories/i_material_repository.dart';
import '../../domain/usecases/material/get_all_materials_usecase.dart';
import '../../domain/usecases/material/search_materials_usecase.dart';
import '../../domain/usecases/material/get_suggested_materials_usecase.dart';

// ==================== Data Source ====================
final materialRemoteDataSourceProvider = Provider<MaterialRemoteDataSource>((ref) {
  return MaterialRemoteDataSource(apiClient: ApiClient.instance);
});

// ==================== Repository ====================
final materialRepositoryProvider = Provider<IMaterialRepository>((ref) {
  final dataSource = ref.read(materialRemoteDataSourceProvider);
  return MaterialRepositoryImpl(remoteDataSource: dataSource);
});

// ==================== Use Cases ====================
final getAllMaterialsUseCaseProvider = Provider<GetAllMaterialsUseCase>((ref) {
  final repository = ref.read(materialRepositoryProvider);
  return GetAllMaterialsUseCase(repository);
});

final searchMaterialsUseCaseProvider = Provider<SearchMaterialsUseCase>((ref) {
  final repository = ref.read(materialRepositoryProvider);
  return SearchMaterialsUseCase(repository);
});

final getSuggestedMaterialsUseCaseProvider = Provider<GetSuggestedMaterialsUseCase>((ref) {
  final repository = ref.read(materialRepositoryProvider);
  return GetSuggestedMaterialsUseCase(repository);
});
