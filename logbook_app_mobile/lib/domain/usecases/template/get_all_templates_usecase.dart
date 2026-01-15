// lib/domain/usecases/template/get_all_templates_usecase.dart

import '../../entities/template_entity.dart';
import '../../repositories/i_template_repository.dart';

class GetAllTemplatesUseCase {
  final ITemplateRepository _repository;

  GetAllTemplatesUseCase(this._repository);

  Future<List<TemplateEntity>> call() async {
    return await _repository.getAllTemplates();
  }
}
