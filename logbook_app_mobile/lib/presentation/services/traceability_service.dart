// lib/presentation/services/traceability_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/traceability_entity.dart';
import '../../data/models/traceability_dto.dart';

class TraceabilityService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Lấy thông tin truy xuất nguồn gốc theo seasonId
  Future<TraceabilityEntity> getTraceability(String seasonId) async {
    try {
      _logger.debug('Fetching traceability data for season: $seasonId');

      final response = await _apiClient.get('/traceability/$seasonId');
      
      // Xử lý response format từ backend
      final responseData = response['data'] ?? response;
      final traceabilityJson = responseData['traceability'];
      
      if (traceabilityJson == null) {
        throw ParseException.invalidJson();
      }
      
      final data = TraceabilityDTO.fromJson(traceabilityJson).toEntity();
      _logger.info('Traceability data loaded successfully');
      return data;
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw const ServerException('Không tìm thấy mã lô/mùa vụ', statusCode: 404);
      }
      rethrow;
    } catch (e) {
      _logger.error('Failed to load traceability data', e);
      rethrow;
    }
  }

  // Tìm kiếm theo mã lô
  Future<TraceabilityEntity> searchByLotCode(String lotCode) async {
    try {
      _logger.debug('Searching traceability by lot code: $lotCode');

      final response = await _apiClient.get('/traceability/search/$lotCode');
      
      final responseData = response['data'] ?? response;
      final traceabilityJson = responseData['traceability'];
      
      if (traceabilityJson == null) {
        throw ParseException.invalidJson();
      }
      
      final data = TraceabilityDTO.fromJson(traceabilityJson).toEntity();
      _logger.info('Traceability data found for lot code');
      return data;
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw const ServerException('Không tìm thấy thông tin với mã lô này', statusCode: 404);
      }
      rethrow;
    } catch (e) {
      _logger.error('Failed to search by lot code', e);
      rethrow;
    }
  }
}
