// lib/services/traceability_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/traceability.dart';

class TraceabilityService {
  // Lấy thông tin truy xuất nguồn gốc theo seasonId
  Future<TraceabilityData> getTraceability(String seasonId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/traceability/$seasonId');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Xử lý response format từ backend (có success và data wrapper)
        final responseData = data['data'] ?? data;
        final traceabilityJson = responseData['traceability'];
        
        if (traceabilityJson == null) {
          throw Exception('Không có dữ liệu truy xuất');
        }
        
        return TraceabilityData.fromJson(traceabilityJson);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy mã lô/mùa vụ');
      } else {
        throw Exception('Lỗi khi tải dữ liệu truy xuất: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Tìm kiếm theo mã lô
  Future<TraceabilityData> searchByLotCode(String lotCode) async {
    final url = Uri.parse('${AppConstants.baseUrl}/traceability/search/$lotCode');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['data'] ?? data;
        final traceabilityJson = responseData['traceability'];
        
        if (traceabilityJson == null) {
          throw Exception('Không có dữ liệu truy xuất');
        }
        
        return TraceabilityData.fromJson(traceabilityJson);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông tin với mã lô này');
      } else {
        throw Exception('Lỗi khi tìm kiếm: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
