// lib/domain/usecases/traceability/get_traceability_usecase.dart

import '../../entities/traceability_entity.dart';
import '../../repositories/i_traceability_repository.dart';

class GetTraceabilityUseCase {
  final ITraceabilityRepository _repository;

  GetTraceabilityUseCase(this._repository);

  Future<TraceabilityEntity> call(String seasonId) async {
    if (seasonId.isEmpty) {
      throw ArgumentError('Season ID cannot be empty');
    }
    return await _repository.getTraceability(seasonId);
  }
}
