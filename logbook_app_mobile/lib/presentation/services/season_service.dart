// lib/presentation/services/season_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/season_entity.dart';
import '../../data/models/season_dto.dart';

class SeasonService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Lấy danh sách mùa vụ của user
  Future<List<SeasonEntity>> getUserSeasons() async {
    try {
      _logger.debug('Fetching user seasons');

      final response = await _apiClient.get('/seasons/user');
      
      // Xử lý response format từ backend
      final responseData = response['data'] ?? response;
      final List<dynamic>? seasonsJson = responseData['seasons'];
      
      if (seasonsJson == null || seasonsJson.isEmpty) {
        _logger.debug('No seasons found for user');
        return [];
      }
      
      final seasons = seasonsJson.map((json) => SeasonDTO.fromJson(json).toEntity()).toList();
      _logger.info('Loaded ${seasons.length} seasons');
      
      return seasons;
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return []; // Chưa có mùa vụ nào
      }
      rethrow;
    } catch (e) {
      _logger.error('Failed to load seasons', e);
      rethrow;
    }
  }

  // Tạo mùa vụ mới
  Future<SeasonEntity> createSeason({
    required String seasonName,
    required String? farmArea,
    required DateTime startDate,
    String? templateId,
  }) async {
    try {
      _logger.info('Creating new season: $seasonName');

      final body = {
        'seasonName': seasonName,
        'farmArea': farmArea,
        'startDate': startDate.toIso8601String(),
        if (templateId != null) 'templateId': templateId,
      };

      final response = await _apiClient.post('/seasons', data: body);
      
      final data = response['data'];
      if (data == null) {
        throw ParseException.invalidJson();
      }
      
      final seasonData = data['season'];
      if (seasonData == null) {
        throw ParseException.invalidJson();
      }

      final season = SeasonDTO.fromJson(seasonData).toEntity();
      _logger.info('Season created successfully: ${season.id}');
      
      return season;
    } catch (e) {
      _logger.error('Failed to create season', e);
      rethrow;
    }
  }

  // Xóa mùa vụ
  Future<void> deleteSeason(String seasonId) async {
    try {
      _logger.info('Deleting season: $seasonId');
      
      await _apiClient.delete('/seasons/$seasonId');
      
      _logger.info('Season deleted successfully');
    } catch (e) {
      _logger.error('Failed to delete season', e);
      rethrow;
    }
  }
}