// lib/domain/usecases/season/create_season_usecase.dart

import '../../entities/season_entity.dart';
import '../../repositories/i_season_repository.dart';

class CreateSeasonUseCase {
  final ISeasonRepository _repository;

  CreateSeasonUseCase(this._repository);

  Future<SeasonEntity> execute({
    required String seasonName,
    String? farmArea,
    String? farmLocation,
    required DateTime startDate,
    String? templateId,
  }) async {
    if (seasonName.isEmpty) {
      throw ArgumentError('Season name cannot be empty');
    }

    return await _repository.createSeason(
      seasonName: seasonName,
      farmArea: farmArea,
      farmLocation: farmLocation,
      startDate: startDate,
      templateId: templateId,
    );
  }
}
