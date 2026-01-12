// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/season_selection_screen.dart';
import 'utils/storage_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StorageHelper.isLoggedIn(),
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