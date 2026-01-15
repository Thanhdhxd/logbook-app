// lib/data/datasources/material_remote_datasource.dart

import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../data/models/material_dto.dart';

class MaterialRemoteDataSource {
  final ApiClient _apiClient;
  final _logger = AppLogger.instance;

  MaterialRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<MaterialDTO>> getAllMaterials() async {
    _logger.info('MaterialDataSource: Fetching all materials');

    final response = await _apiClient.get('/materials');

    if (response['data'] is List) {
      final List<dynamic> materialsData = response['data'];
      return materialsData.map((json) => MaterialDTO.fromJson(json)).toList();
    } else if (response['materials'] is List) {
      final List<dynamic> materialsData = response['materials'];
      return materialsData.map((json) => MaterialDTO.fromJson(json)).toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    final response = await _apiClient.get(
      '/materials/search',
      queryParameters: {'q': query},
    );

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getSuggestedMaterials(
    String seasonId,
    String taskName,
  ) async {
    final response = await _apiClient.get(
      '/seasons/$seasonId/suggested-materials',
      queryParameters: {'taskName': taskName},
    );

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>?> getMaterialByBarcode(String barcode) async {
    try {
      final response = await _apiClient.get(
        '/materials/barcode/$barcode',
      );
      return response['data'];
    } catch (e) {
      _logger.warning('Material not found for barcode: $barcode');
      return null;
    }
  }
}
