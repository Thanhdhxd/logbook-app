// lib/presentation/providers/template_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/template_remote_datasource.dart';
import '../../data/repositories/template_repository_impl.dart';
import '../../domain/repositories/i_template_repository.dart';
import '../../domain/usecases/template/get_all_templates_usecase.dart';
import '../../domain/usecases/template/get_template_by_id_usecase.dart';
import '../../domain/usecases/template/create_template_usecase.dart';
import '../../domain/usecases/template/update_template_usecase.dart';
import '../../domain/usecases/template/delete_template_usecase.dart';
import 'app_providers.dart';

// DataSource Provider
final templateDataSourceProvider = Provider<TemplateRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TemplateRemoteDataSource(apiClient);
});

// Repository Provider
final templateRepositoryProvider = Provider<ITemplateRepository>((ref) {
  final dataSource = ref.watch(templateDataSourceProvider);
  return TemplateRepositoryImpl(dataSource);
});

// Use Case Providers
final getAllTemplatesUseCaseProvider = Provider<GetAllTemplatesUseCase>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return GetAllTemplatesUseCase(repository);
});

final getTemplateByIdUseCaseProvider =
    Provider<GetTemplateByIdUseCase>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return GetTemplateByIdUseCase(repository);
});

final createTemplateUseCaseProvider = Provider<CreateTemplateUseCase>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return CreateTemplateUseCase(repository);
});

final updateTemplateUseCaseProvider = Provider<UpdateTemplateUseCase>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return UpdateTemplateUseCase(repository);
});

final deleteTemplateUseCaseProvider = Provider<DeleteTemplateUseCase>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return DeleteTemplateUseCase(repository);
});
