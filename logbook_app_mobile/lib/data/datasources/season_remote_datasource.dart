// lib/data/datasources/season_remote_datasource.dart

import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../data/models/season_dto.dart';

class SeasonRemoteDataSource {
  final ApiClient _apiClient;
  final _logger = AppLogger.instance;

  SeasonRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<SeasonDTO>> getSeasons(String userId) async {
    _logger.info('SeasonDataSource: Fetching seasons for user $userId');
    
    // Backend gets userId from JWT token, not from URL
    final response = await _apiClient.get('/seasons/user');
    
    // Backend response: { data: { seasons: [...] } }
    final responseData = response['data'];
    final List<dynamic> seasonsData = responseData?['seasons'] ?? [];
    return seasonsData.map((json) => SeasonDTO.fromJson(json)).toList();
  }

  Future<SeasonDTO> createSeason(Map<String, dynamic> data) async {
    _logger.info('SeasonDataSource: Creating new season');
    
    final response = await _apiClient.post('/seasons', data: data);
    
    // Backend returns: { data: { season: {...} } }
    final seasonData = response['data']['season'];
    return SeasonDTO.fromJson(seasonData);
  }

  Future<void> deleteSeason(String seasonId) async {
    _logger.info('SeasonDataSource: Deleting season $seasonId');
    await _apiClient.delete('/seasons/$seasonId');
  }

  Future<SeasonDTO> getSeasonById(String seasonId) async {
    final response = await _apiClient.get('/seasons/$seasonId');
    return SeasonDTO.fromJson(response['data']);
  }
}
