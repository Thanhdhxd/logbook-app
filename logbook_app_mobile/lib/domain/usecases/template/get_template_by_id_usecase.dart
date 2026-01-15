// lib/domain/usecases/template/get_template_by_id_usecase.dart

import '../../entities/template_entity.dart';
import '../../repositories/i_template_repository.dart';

class GetTemplateByIdUseCase {
  final ITemplateRepository _repository;

  GetTemplateByIdUseCase(this._repository);

  Future<TemplateEntity> call(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Template ID cannot be empty');
    }
    return await _repository.getTemplateById(id);
  }
}
