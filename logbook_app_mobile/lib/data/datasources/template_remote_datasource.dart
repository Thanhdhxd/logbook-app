// lib/data/datasources/template_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/template_dto.dart';

class TemplateRemoteDataSource {
  final ApiClient _apiClient;

  TemplateRemoteDataSource(this._apiClient);

  Future<List<TemplateDTO>> getAllTemplates() async {
    final response = await _apiClient.get('/templates');
    final List<dynamic> data = response['templates'] ?? [];
    return data.map((json) => TemplateDTO.fromJson(json)).toList();
  }

  Future<TemplateDTO> getTemplateById(String id) async {
    final response = await _apiClient.get('/templates/$id');
    return TemplateDTO.fromJson(response['data']);
  }

  Future<TemplateDTO> createTemplate(TemplateDTO template) async {
    final response = await _apiClient.post(
      '/templates',
      data: template.toJson(),
    );
    return TemplateDTO.fromJson(response['data']);
  }

  Future<TemplateDTO> updateTemplate(String id, TemplateDTO template) async {
    final response = await _apiClient.put(
      '/templates/$id',
      data: template.toJson(),
    );
    return TemplateDTO.fromJson(response['template']);
  }

  Future<void> deleteTemplate(String id) async {
    await _apiClient.delete('/templates/$id');
  }
}
