// lib/data/repositories/template_repository_impl.dart

import '../../domain/entities/template_entity.dart';
import '../../domain/repositories/i_template_repository.dart';
import '../datasources/template_remote_datasource.dart';
import '../../data/models/template_dto.dart';

class TemplateRepositoryImpl implements ITemplateRepository {
  final TemplateRemoteDataSource _remoteDataSource;

  TemplateRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TemplateEntity>> getAllTemplates() async {
    final dtos = await _remoteDataSource.getAllTemplates();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<TemplateEntity> getTemplateById(String id) async {
    final dto = await _remoteDataSource.getTemplateById(id);
    return dto.toEntity();
  }

  @override
  Future<TemplateEntity> createTemplate(TemplateEntity template) async {
    final dto = TemplateDTO.fromEntity(template);
    final resultDto = await _remoteDataSource.createTemplate(dto);
    return resultDto.toEntity();
  }

  @override
  Future<TemplateEntity> updateTemplate(
      String id, TemplateEntity template) async {
    final dto = TemplateDTO.fromEntity(template);
    final resultDto = await _remoteDataSource.updateTemplate(id, dto);
    return resultDto.toEntity();
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _remoteDataSource.deleteTemplate(id);
  }
}
