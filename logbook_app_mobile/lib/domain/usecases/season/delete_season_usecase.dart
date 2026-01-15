// lib/domain/usecases/season/delete_season_usecase.dart

import '../../repositories/i_season_repository.dart';

class DeleteSeasonUseCase {
  final ISeasonRepository _repository;

  DeleteSeasonUseCase(this._repository);

  Future<void> execute(String seasonId) async {
    if (seasonId.isEmpty) {
      throw ArgumentError('Season ID cannot be empty');
    }
    await _repository.deleteSeason(seasonId);
  }
}
