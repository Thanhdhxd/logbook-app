// lib/domain/usecases/template/create_template_usecase.dart

import '../../entities/template_entity.dart';
import '../../repositories/i_template_repository.dart';

class CreateTemplateUseCase {
  final ITemplateRepository _repository;

  CreateTemplateUseCase(this._repository);

  Future<TemplateEntity> call(TemplateEntity template) async {
    if (template.templateName.isEmpty) {
      throw ArgumentError('Template name cannot be empty');
    }
    if (template.cropType.isEmpty) {
      throw ArgumentError('Crop type cannot be empty');
    }
    return await _repository.createTemplate(template);
  }
}
