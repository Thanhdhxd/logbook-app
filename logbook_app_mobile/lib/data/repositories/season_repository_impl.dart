// lib/data/repositories/season_repository_impl.dart

import '../../domain/entities/season_entity.dart';
import '../../domain/repositories/i_season_repository.dart';
import '../../core/network/app_logger.dart';
import '../datasources/season_remote_datasource.dart';

class SeasonRepositoryImpl implements ISeasonRepository {
  final SeasonRemoteDataSource _remoteDataSource;
  final _logger = AppLogger.instance;

  SeasonRepositoryImpl({required SeasonRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SeasonEntity>> getSeasons(String userId) async {
    try {
      final dtos = await _remoteDataSource.getSeasons(userId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      _logger.error('SeasonRepository: Failed to get seasons', e);
      rethrow;
    }
  }

  @override
  Future<SeasonEntity> createSeason({
    required String seasonName,
    String? farmArea,
    String? farmLocation,
    required DateTime startDate,
    String? templateId,
  }) async {
    try {
      final data = {
        'seasonName': seasonName,
        'farmArea': farmArea,
        'farmLocation': farmLocation,
        'startDate': startDate.toIso8601String(),
        if (templateId != null) 'templateId': templateId,
      };

      final dto = await _remoteDataSource.createSeason(data);
      return dto.toEntity();
    } catch (e) {
      _logger.error('SeasonRepository: Failed to create season', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSeason(String seasonId) async {
    try {
      await _remoteDataSource.deleteSeason(seasonId);
    } catch (e) {
      _logger.error('SeasonRepository: Failed to delete season', e);
      rethrow;
    }
  }

  @override
  Future<SeasonEntity> getSeasonById(String seasonId) async {
    try {
      final dto = await _remoteDataSource.getSeasonById(seasonId);
      return dto.toEntity();
    } catch (e) {
      _logger.error('SeasonRepository: Failed to get season by ID', e);
      rethrow;
    }
  }
}
