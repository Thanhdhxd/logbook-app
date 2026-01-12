// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../utils/storage_helper.dart';

class AuthService {
  static const String _loginUrl = '${AppConstants.baseUrl}/auth/login';
  static const String _verifyUrl = '${AppConstants.baseUrl}/auth/verify';

  // Đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Lưu token và thông tin user
        final token = data['data']['token'];
        final user = data['data']['user'];
        
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUserInfo(
          userId: user['id'],
          userName: user['name'],
          userEmail: user['email'],
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Đăng nhập thành công',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Xác thực token
  static Future<bool> verifyToken() async {
    try {
      final token = await StorageHelper.getToken();
      
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.post(
        Uri.parse(_verifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Đăng xuất
  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  // Lấy header với token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
}
