// lib/domain/usecases/template/delete_template_usecase.dart

import '../../repositories/i_template_repository.dart';

class DeleteTemplateUseCase {
  final ITemplateRepository _repository;

  DeleteTemplateUseCase(this._repository);

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Template ID cannot be empty');
    }
    return await _repository.deleteTemplate(id);
  }
}
