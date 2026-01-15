// lib/domain/repositories/i_template_repository.dart

import '../entities/template_entity.dart';

abstract class ITemplateRepository {
  Future<List<TemplateEntity>> getAllTemplates();
  Future<TemplateEntity> getTemplateById(String id);
  Future<TemplateEntity> createTemplate(TemplateEntity template);
  Future<TemplateEntity> updateTemplate(String id, TemplateEntity template);
  Future<void> deleteTemplate(String id);
}
