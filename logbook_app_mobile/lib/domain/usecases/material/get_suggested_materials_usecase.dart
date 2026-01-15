// lib/domain/usecases/material/get_suggested_materials_usecase.dart

import '../../repositories/i_material_repository.dart';

class GetSuggestedMaterialsUseCase {
  final IMaterialRepository _repository;

  GetSuggestedMaterialsUseCase(this._repository);

  Future<List<Map<String, dynamic>>> execute(
    String seasonId,
    String taskName,
  ) async {
    if (seasonId.isEmpty || taskName.isEmpty) {
      return [];
    }
    return await _repository.getSuggestedMaterials(seasonId, taskName);
  }
}
