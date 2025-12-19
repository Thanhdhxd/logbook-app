// lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackbarHelper {
  /// Hiển thị thông báo thành công ở góc trên phải màn hình
  static void showSuccess(BuildContext context, String message) {
    _showTopNotification(
      context,
      message,
      backgroundColor: const Color(0xFF4CAF50),
      icon: Icons.check_circle_outline,
    );
  }

  /// Hiển thị thông báo lỗi ở góc trên phải màn hình
  static void showError(BuildContext context, String message) {
    _showTopNotification(
      context,
      message,
      backgroundColor: const Color(0xFFE53935),
      icon: Icons.error_outline,
    );
  }

  /// Hiển thị thông báo cảnh báo ở góc trên phải màn hình
  static void showWarning(BuildContext context, String message) {
    _showTopNotification(
      context,
      message,
      backgroundColor: const Color(0xFFFB8C00),
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Hiển thị thông báo thông tin ở góc trên phải màn hình
  static void showInfo(BuildContext context, String message) {
    _showTopNotification(
      context,
      message,
      backgroundColor: const Color(0xFF1E88E5),
      icon: Icons.info_outline,
    );
  }

  static void _showTopNotification(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Không có màn đen phủ
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Placeholder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return Stack(
          children: [
            Positioned(
              top: 80,
              right: 16,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: FadeTransition(
                  opacity: curvedAnimation,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                        minWidth: 280,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Tự động đóng sau 2.5 giây
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}
