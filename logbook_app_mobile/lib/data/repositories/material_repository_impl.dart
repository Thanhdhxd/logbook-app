// lib/data/repositories/material_repository_impl.dart

import '../../domain/entities/material_entity.dart';
import '../../domain/repositories/i_material_repository.dart';
import '../../core/network/app_logger.dart';
import '../datasources/material_remote_datasource.dart';

class MaterialRepositoryImpl implements IMaterialRepository {
  final MaterialRemoteDataSource _remoteDataSource;
  final _logger = AppLogger.instance;

  MaterialRepositoryImpl({required MaterialRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<MaterialEntity>> getAllMaterials() async {
    try {
      final dtos = await _remoteDataSource.getAllMaterials();
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      _logger.error('MaterialRepository: Failed to get all materials', e);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    try {
      return await _remoteDataSource.searchMaterials(query);
    } catch (e) {
      _logger.error('MaterialRepository: Failed to search materials', e);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedMaterials(
    String seasonId,
    String taskName,
  ) async {
    try {
      return await _remoteDataSource.getSuggestedMaterials(seasonId, taskName);
    } catch (e) {
      _logger.error('MaterialRepository: Failed to get suggested materials', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getMaterialByBarcode(String barcode) async {
    try {
      return await _remoteDataSource.getMaterialByBarcode(barcode);
    } catch (e) {
      _logger.error('MaterialRepository: Failed to get material by barcode', e);
      return null;
    }
  }
}
