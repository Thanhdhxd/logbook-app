// lib/data/repositories/traceability_repository_impl.dart

import '../../domain/entities/traceability_entity.dart';
import '../../domain/repositories/i_traceability_repository.dart';
import '../datasources/traceability_remote_datasource.dart';

class TraceabilityRepositoryImpl implements ITraceabilityRepository {
  final TraceabilityRemoteDataSource _remoteDataSource;

  TraceabilityRepositoryImpl(this._remoteDataSource);

  @override
  Future<TraceabilityEntity> getTraceability(String seasonId) async {
    final dto = await _remoteDataSource.getTraceability(seasonId);
    return dto.toEntity();
  }
}
