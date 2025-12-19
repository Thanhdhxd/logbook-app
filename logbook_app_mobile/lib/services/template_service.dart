// lib/services/template_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/plan_template.dart';

class TemplateService {
  // Lấy danh sách tất cả templates
  Future<List<PlanTemplate>> getAllTemplates() async {
    final url = Uri.parse('${AppConstants.templatesUrl}');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> templatesJson = data['templates'] ?? [];
        
        return templatesJson
            .map((json) => PlanTemplate.fromJson(json))
            .toList();
      } else {
        throw Exception('Lỗi khi tải danh sách kế hoạch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Tạo template mới
  Future<PlanTemplate> createTemplate(PlanTemplate template) async {
    final url = Uri.parse('${AppConstants.templatesUrl}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(template.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return PlanTemplate.fromJson(data['template']);
      } else {
        throw Exception('Lỗi khi tạo kế hoạch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Cập nhật template
  Future<PlanTemplate> updateTemplate(String templateId, PlanTemplate template) async {
    final url = Uri.parse('${AppConstants.templatesUrl}/$templateId');
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(template.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlanTemplate.fromJson(data['template']);
      } else {
        throw Exception('Lỗi khi cập nhật kế hoạch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  // Xóa template
  Future<bool> deleteTemplate(String templateId) async {
    final url = Uri.parse('${AppConstants.templatesUrl}/$templateId');
    
    try {
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Lỗi khi xóa kế hoạch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
