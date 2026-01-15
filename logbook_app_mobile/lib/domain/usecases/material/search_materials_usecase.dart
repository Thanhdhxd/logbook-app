// lib/domain/usecases/material/search_materials_usecase.dart

import '../../repositories/i_material_repository.dart';

class SearchMaterialsUseCase {
  final IMaterialRepository _repository;

  SearchMaterialsUseCase(this._repository);

  Future<List<Map<String, dynamic>>> execute(String query) async {
    if (query.isEmpty) {
      return [];
    }
    return await _repository.searchMaterials(query);
  }
}
