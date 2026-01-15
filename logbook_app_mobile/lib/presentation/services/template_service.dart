// lib/presentation/services/template_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../domain/entities/template_entity.dart';
import '../../data/models/template_dto.dart';

class TemplateService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Lấy danh sách tất cả templates
  Future<List<TemplateEntity>> getAllTemplates() async {
    try {
      _logger.debug('Fetching all templates');

      final response = await _apiClient.get('/templates');
      final List<dynamic> templatesJson = response['templates'] ?? [];
      
      final templates = templatesJson
          .map((json) => TemplateDTO.fromJson(json).toEntity())
          .toList();
      
      _logger.info('Loaded ${templates.length} templates');
      return templates;
    } catch (e) {
      _logger.error('Failed to load templates', e);
      rethrow;
    }
  }

  // Tạo template mới
  Future<TemplateEntity> createTemplate(TemplateEntity template) async {
    try {
      _logger.info('Creating new template: ${template.templateName}');

      final dto = TemplateDTO.fromEntity(template);
      final response = await _apiClient.post(
        '/templates',
        data: dto.toJson(),
      );
      
      final newTemplate = TemplateDTO.fromJson(response['template']).toEntity();
      _logger.info('Template created successfully');
      return newTemplate;
    } catch (e) {
      _logger.error('Failed to create template', e);
      rethrow;
    }
  }

  // Cập nhật template
  Future<TemplateEntity> updateTemplate(String templateId, TemplateEntity template) async {
    try {
      _logger.info('Updating template: $templateId');

      final dto = TemplateDTO.fromEntity(template);
      final response = await _apiClient.put(
        '/templates/$templateId',
        data: dto.toJson(),
      );
      
      final updatedTemplate = TemplateDTO.fromJson(response['template']).toEntity();
      _logger.info('Template updated successfully');
      return updatedTemplate;
    } catch (e) {
      _logger.error('Failed to update template', e);
      rethrow;
    }
  }

  // Xóa template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      _logger.info('Deleting template: $templateId');

      await _apiClient.delete('/templates/$templateId');
      
      _logger.info('Template deleted successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to delete template', e);
      rethrow;
    }
  }
}
