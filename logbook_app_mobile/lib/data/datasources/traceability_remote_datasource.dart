// lib/data/datasources/traceability_remote_datasource.dart

import '../../core/network/api_client.dart';
import '../../data/models/traceability_dto.dart';

class TraceabilityRemoteDataSource {
  final ApiClient _apiClient;

  TraceabilityRemoteDataSource(this._apiClient);

  Future<TraceabilityDTO> getTraceability(String seasonId) async {
    // Backend route: GET /traceability/:seasonId
    final response = await _apiClient.get('/traceability/$seasonId');
    // API returns: { data: { traceability: {...} } }
    return TraceabilityDTO.fromJson(response['data']['traceability']);
  }
}
