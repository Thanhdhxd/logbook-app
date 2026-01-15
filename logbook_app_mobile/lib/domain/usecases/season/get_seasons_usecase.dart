// lib/domain/usecases/season/get_seasons_usecase.dart

import '../../entities/season_entity.dart';
import '../../repositories/i_season_repository.dart';

class GetSeasonsUseCase {
  final ISeasonRepository _repository;

  GetSeasonsUseCase(this._repository);

  Future<List<SeasonEntity>> execute(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return await _repository.getSeasons(userId);
  }
}
