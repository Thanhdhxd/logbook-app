// lib/services/material_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/material_entity.dart';

class MaterialService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Lấy danh sách tất cả vật tư
  Future<List<MaterialEntity>> getAllMaterials() async {
    try {
      _logger.debug('Fetching all materials');

      final response = await _apiClient.get('/materials');
      
      // Xử lý response có thể là array trực tiếp hoặc wrapped trong data
      List<dynamic> materialsJson;
      if (response['data'] != null) {
        final data = response['data'];
        materialsJson = data is List ? data : [];
      } else if (response is Map) {
        materialsJson = [];
      } else {
        materialsJson = [];
      }
      
      final materials = materialsJson.map((json) => MaterialEntity(
        id: json['_id'] ?? '',
        materialName: json['materialName'] ?? '',
        category: json['category'] ?? '',
        unit: json['unit'] ?? 'kg',
      )).toList();
      _logger.info('Loaded ${materials.length} materials');
      
      return materials;
    } catch (e) {
      _logger.error('Failed to load materials', e);
      rethrow;
    }
  }

  // Lấy vật tư gợi ý cho công việc
  Future<List<dynamic>> getSuggestedMaterials(
      String seasonId, String taskName) async {
    try {
      _logger.debug('Fetching suggested materials for task: $taskName');
      
      final response = await _apiClient.get(
        '/materials/suggested/$seasonId/$taskName',
      );
      
      return response['suggestedMaterials'] ?? [];
    } catch (e) {
      _logger.warning('Failed to get suggested materials', e);
      return [];
    }
  }

  // Lấy vật tư hay dùng nhất của user
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      _logger.debug('Fetching favorite materials');
      
      final response = await _apiClient.get('/materials/favorites');
      final responseData = response['data'] ?? response;
      final List<dynamic>? favoritesJson = responseData['favorites'];
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      return favoritesJson.map<Map<String, dynamic>>((item) => {
        'materialName': item['materialName'] ?? '',
        'usageCount': item['usageCount'] ?? 0,
        'unit': item['unit'] ?? 'kg',
      }).toList();
    } catch (e) {
      _logger.warning('Failed to get favorite materials', e);
      return [];
    }
  }

  // Tìm kiếm vật tư theo tên
  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    try {
      final allMaterials = await getAllMaterials();
      final searchQuery = query.toLowerCase();
      
      // Filter materials theo tên
      final filtered = allMaterials
          .where((m) => m.materialName.toLowerCase().contains(searchQuery))
          .map((m) => {
                'name': m.materialName,
                'unit': m.unit,
                'category': m.category,
              })
          .toList();
      
      return filtered;
    } catch (e) {
      print('Lỗi khi tìm kiếm vật tư: $e');
      return [];
    }
  }

  // Tìm vật tư theo barcode
  Future<Map<String, dynamic>?> getMaterialByBarcode(String barcode) async {
    try {
      _logger.debug('Searching material by barcode: $barcode');

      final response = await _apiClient.get('/materials/barcode/$barcode');
      final materialData = response['data'] ?? response;
      
      _logger.info('Material found by barcode');
      return {
        'name': materialData['materialName'] ?? '',
        'unit': materialData['unit'] ?? 'kg',
        'category': materialData['category'] ?? '',
        'barcode': materialData['barcode'] ?? '',
      };
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        _logger.debug('Material not found with barcode: $barcode');
        return null; // Không tìm thấy vật tư với barcode này
      }
      rethrow;
    } catch (e) {
      _logger.error('Failed to search material by barcode', e);
      rethrow;
    }
  }
}
