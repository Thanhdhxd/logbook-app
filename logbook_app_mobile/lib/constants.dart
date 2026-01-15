// lib/constants.dart
// DEPRECATED: Dùng config/environment.dart thay thế
// File này giữ lại để backward compatibility

import 'config/environment.dart';

class AppConstants {
  // DEPRECATED: Sử dụng Environment.apiUrl thay thế
  static String get baseUrl => Environment.apiUrl;
  
  // Các endpoint cụ thể (deprecated, nên dùng path trực tiếp trong services)
  static String get seasonsUrl => '$baseUrl/seasons';
  static String get logbookUrl => '$baseUrl/logbook';
  static String get materialsUrl => '$baseUrl/materials';
  static String get templatesUrl => '$baseUrl/templates';
}