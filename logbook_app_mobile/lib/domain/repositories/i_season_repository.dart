// lib/domain/repositories/i_season_repository.dart

import '../entities/season_entity.dart';

abstract class ISeasonRepository {
  /// Get all seasons for a user
  Future<List<SeasonEntity>> getSeasons(String userId);

  /// Create new season
  Future<SeasonEntity> createSeason({
    required String seasonName,
    String? farmArea,
    String? farmLocation,
    required DateTime startDate,
    String? templateId,
  });

  /// Delete season
  Future<void> deleteSeason(String seasonId);

  /// Get season by ID
  Future<SeasonEntity> getSeasonById(String seasonId);
}
