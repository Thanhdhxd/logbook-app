// lib/presentation/providers/storage_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';

/// Provider for SecureStorageService
/// Use this instead of directly calling SecureStorageService.instance
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});
