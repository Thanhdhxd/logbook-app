// services/blockchain_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class BlockchainService {
  // Ghi nhật ký lên blockchain
  Future<Map<String, dynamic>?> recordLog({
    required String logId,
    required String taskName,
    required String seasonId,
    required List<Map<String, dynamic>> materials,
    required DateTime timestamp,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/blockchain/record');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'logId': logId,
          'taskName': taskName,
          'seasonId': seasonId,
          'materials': materials,
          'timestamp': timestamp.toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'transactionHash': data['data']['transactionHash'],
          'blockNumber': data['data']['blockNumber'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Xác thực log từ blockchain
  Future<Map<String, dynamic>?> verifyLog(String logId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/blockchain/verify/$logId');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'verified': data['data']['verified'],
          'transactionHash': data['data']['transactionHash'],
          'timestamp': data['data']['timestamp'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
