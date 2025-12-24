// lib/services/season_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/season.dart';

class SeasonService {
  // Lấy danh sách mùa vụ của user
  Future<List<Season>> getUserSeasons() async {
    final url = Uri.parse('${AppConstants.seasonsUrl}/user');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Xử lý response format mới từ backend (có success và data wrapper)
        final responseData = data['data'] ?? data;
        final List<dynamic>? seasonsJson = responseData['seasons'];
        
        if (seasonsJson == null || seasonsJson.isEmpty) {
          return [];
        }
        
        return seasonsJson.map((json) => Season.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // Chưa có mùa vụ nào
      } else {
        throw Exception('Lỗi khi tải mùa vụ: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Tạo mùa vụ mới - Backend sẽ tự động matching template dựa vào seasonName
  Future<Season> createSeason({
    required String seasonName,
    required String? farmArea,
    required DateTime startDate,
    String? templateId,
  }) async {
    final url = Uri.parse(AppConstants.seasonsUrl);
    try {
      final body = {
        'seasonName': seasonName,
        'farmArea': farmArea,
        'startDate': startDate.toIso8601String(),
      };
      if (templateId != null) {
        body['templateId'] = templateId;
      }
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 201) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Backend trả về response rỗng');
        }
        final responseData = json.decode(responseBody);
        if (responseData == null) {
          throw Exception('Không thể parse response từ backend');
        }
        final data = responseData['data'];
        if (data == null) {
          throw Exception('Backend không trả về data');
        }
        final seasonData = data['season'];
        if (seasonData == null) {
          throw Exception('Backend không trả về thông tin mùa vụ');
        }
        return Season.fromJson(seasonData);
      } else {
        throw Exception('Lỗi khi tạo mùa vụ: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  Future<void> deleteSeason(String seasonId) async {
    final url = Uri.parse('${AppConstants.seasonsUrl}/$seasonId');
    
    try {
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Lỗi khi xóa mùa vụ: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}