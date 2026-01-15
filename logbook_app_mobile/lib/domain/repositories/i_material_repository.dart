// lib/domain/repositories/i_material_repository.dart

import '../entities/material_entity.dart';

abstract class IMaterialRepository {
  /// Get all materials
  Future<List<MaterialEntity>> getAllMaterials();

  /// Search materials by name
  Future<List<Map<String, dynamic>>> searchMaterials(String query);

  /// Get suggested materials for a task
  Future<List<Map<String, dynamic>>> getSuggestedMaterials(
    String seasonId,
    String taskName,
  );

  /// Get material by barcode
  Future<Map<String, dynamic>?> getMaterialByBarcode(String barcode);
}
