// lib/domain/usecases/material/get_all_materials_usecase.dart

import '../../entities/material_entity.dart';
import '../../repositories/i_material_repository.dart';

class GetAllMaterialsUseCase {
  final IMaterialRepository _repository;

  GetAllMaterialsUseCase(this._repository);

  Future<List<MaterialEntity>> execute() async {
    return await _repository.getAllMaterials();
  }
}
