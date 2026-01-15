// lib/presentation/providers/app_providers.dart

/// Central export file for all application providers
/// Import this file instead of individual provider files

// Auth providers
export 'auth_providers.dart';

// Season providers
export 'season_providers.dart';

// Task providers
export 'task_providers.dart';

// Material providers
export 'material_providers.dart';

// Template providers
export 'template_providers.dart';

// Traceability providers
export 'traceability_providers.dart';

// Storage provider
export 'storage_provider.dart';

// Service providers (legacy helper services)
export 'service_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});
