// lib/constants.dart
class AppConstants {
  // Đổi thành URL backend production khi deploy
  // Development: http://127.0.0.1:5000/api
  // Production: https://logbook-backend.onrender.com/api
  static const String baseUrl = 'https://logbook-backend.onrender.com/api';
  
  // Các endpoint cụ thể
  static const String seasonsUrl = '$baseUrl/seasons';
  static const String logbookUrl = '$baseUrl/logbook';
  static const String materialsUrl = '$baseUrl/materials';
  static const String templatesUrl = '$baseUrl/templates';
}