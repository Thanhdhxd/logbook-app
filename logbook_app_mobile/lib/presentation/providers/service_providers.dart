// lib/presentation/providers/service_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/season_service.dart';
import '../services/task_service.dart';
import '../services/material_service.dart';
import '../services/template_service.dart';
import '../services/traceability_service.dart';
import '../services/blockchain_service.dart';

/// Service layer providers for helper functions
/// These wrap legacy services that provide complex operations

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final seasonServiceProvider = Provider<SeasonService>((ref) {
  return SeasonService();
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

final materialServiceProvider = Provider<MaterialService>((ref) {
  return MaterialService();
});

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

final traceabilityServiceProvider = Provider<TraceabilityService>((ref) {
  return TraceabilityService();
});

final blockchainServiceProvider = Provider<BlockchainService>((ref) {
  return BlockchainService();
});
