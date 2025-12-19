// lib/services/material_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/material.dart';

class MaterialService {
  // Lấy danh sách tất cả vật tư
  Future<List<Material>> getAllMaterials() async {
    final url = Uri.parse(AppConstants.materialsUrl);
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Xử lý response có thể là array trực tiếp hoặc wrapped trong data
        List<dynamic> materialsJson;
        if (data is List) {
          materialsJson = data;
        } else if (data is Map && data['data'] != null) {
          materialsJson = data['data'] is List ? data['data'] : [];
        } else {
          materialsJson = [];
        }
        
        return materialsJson.map((json) => Material.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi tải vật tư: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Lấy vật tư gợi ý cho công việc
  Future<List<dynamic>> getSuggestedMaterials(
      String seasonId, String taskName) async {
    final url = Uri.parse(
        '${AppConstants.materialsUrl}/suggested/$seasonId/$taskName');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['suggestedMaterials'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Lấy vật tư hay dùng nhất của user
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final url = Uri.parse('${AppConstants.materialsUrl}/favorites');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['data'] ?? data;
        final List<dynamic>? favoritesJson = responseData['favorites'];
        
        if (favoritesJson == null || favoritesJson.isEmpty) {
          return [];
        }
        
        return favoritesJson.map<Map<String, dynamic>>((item) => {
          'materialName': item['materialName'] ?? '',
          'usageCount': item['usageCount'] ?? 0,
          'unit': item['unit'] ?? 'kg',
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
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
    final url = Uri.parse('${AppConstants.materialsUrl}/barcode/$barcode');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final materialData = data['data'] ?? data;
        
        return {
          'name': materialData['materialName'] ?? '',
          'unit': materialData['unit'] ?? 'kg',
          'category': materialData['category'] ?? '',
          'barcode': materialData['barcode'] ?? '',
        };
      } else if (response.statusCode == 404) {
        return null; // Không tìm thấy vật tư với barcode này
      } else {
        throw Exception('Lỗi khi tìm vật tư: ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi tìm vật tư theo barcode: $e');
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
