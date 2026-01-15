// lib/presentation/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/verify_token_usecase.dart';
import '../../domain/usecases/auth/check_login_status_usecase.dart';

// ==================== Data Source Providers ====================

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    apiClient: ApiClient.instance,
    secureStorage: SecureStorageService.instance,
  );
});

// ==================== Repository Providers ====================

/// Provider for IAuthRepository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ==================== Use Case Providers ====================

/// Provider for LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provider for LogoutUseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Provider for VerifyTokenUseCase
final verifyTokenUseCaseProvider = Provider<VerifyTokenUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return VerifyTokenUseCase(repository);
});

/// Provider for CheckLoginStatusUseCase
final checkLoginStatusUseCaseProvider = Provider<CheckLoginStatusUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return CheckLoginStatusUseCase(repository);
});
