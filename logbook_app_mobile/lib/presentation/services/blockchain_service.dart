// services/blockchain_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';

class BlockchainService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;

  // Ghi nhật ký lên blockchain
  Future<Map<String, dynamic>?> recordLog({
    required String logId,
    required String taskName,
    required String seasonId,
    required List<Map<String, dynamic>> materials,
    required DateTime timestamp,
  }) async {
    try {
      _logger.info('Recording log to blockchain: $logId');

      final response = await _apiClient.post(
        '/blockchain/record',
        data: {
          'logId': logId,
          'taskName': taskName,
          'seasonId': seasonId,
          'materials': materials,
          'timestamp': timestamp.toIso8601String(),
        },
      );
      
      final data = response['data'];
      _logger.info('Blockchain record successful: ${data['transactionHash']}');
      
      return {
        'success': true,
        'transactionHash': data['transactionHash'],
        'blockNumber': data['blockNumber'],
      };
    } catch (e) {
      _logger.error('Failed to record to blockchain', e);
      return null;
    }
  }

  // Xác thực log từ blockchain
  Future<Map<String, dynamic>?> verifyLog(String logId) async {
    try {
      _logger.debug('Verifying blockchain log: $logId');

      final response = await _apiClient.get('/blockchain/verify/$logId');
      
      final data = response['data'];
      _logger.info('Blockchain verification result: ${data['verified']}');
      
      return {
        'verified': data['verified'],
        'transactionHash': data['transactionHash'],
        'timestamp': data['timestamp'],
      };
    } catch (e) {
      _logger.error('Failed to verify blockchain log', e);
      return null;
    }
  }
}
