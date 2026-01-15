// lib/domain/usecases/template/update_template_usecase.dart

import '../../entities/template_entity.dart';
import '../../repositories/i_template_repository.dart';

class UpdateTemplateUseCase {
  final ITemplateRepository _repository;

  UpdateTemplateUseCase(this._repository);

  Future<TemplateEntity> call(String id, TemplateEntity template) async {
    if (id.isEmpty) {
      throw ArgumentError('Template ID cannot be empty');
    }
    if (template.templateName.isEmpty) {
      throw ArgumentError('Template name cannot be empty');
    }
    if (template.cropType.isEmpty) {
      throw ArgumentError('Crop type cannot be empty');
    }
    return await _repository.updateTemplate(id, template);
  }
}
