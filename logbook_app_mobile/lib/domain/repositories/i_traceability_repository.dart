// lib/domain/repositories/i_traceability_repository.dart

import '../entities/traceability_entity.dart';

abstract class ITraceabilityRepository {
  Future<TraceabilityEntity> getTraceability(String seasonId);
}
