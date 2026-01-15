// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/environment.dart';
import 'core/network/app_logger.dart';
import 'presentation/providers/auth_providers.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/season_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // In thông tin môi trường khi app start
  Environment.printInfo();
  
  // Log app started
  AppLogger.instance.info('🚀 Application started');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký Nông nghiệp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
    );
  }
}

// Widget kiểm tra trạng thái đăng nhập
class AuthCheck extends ConsumerWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkLoginStatusUseCase = ref.read(checkLoginStatusUseCaseProvider);

    return FutureBuilder<bool>(
      future: checkLoginStatusUseCase.execute(),
      builder: (context, snapshot) {
        // Đang kiểm tra
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Đã có kết quả
        final isLoggedIn = snapshot.data ?? false;
        
        if (isLoggedIn) {
          return const SeasonSelectionScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}