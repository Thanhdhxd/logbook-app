// lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackbarHelper {
  static final List<_NotificationItem> _notifications = [];
  static const double _notificationHeight = 70.0; // Chiều cao mỗi thông báo + khoảng cách
  static const double _topStart = 80.0; // Vị trí bắt đầu từ trên xuống

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
    final overlay = Overlay.of(context);
    final notificationItem = _NotificationItem();

    // Đẩy tất cả thông báo cũ xuống dưới
    for (var item in _notifications) {
      item.index++;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        notificationItem: notificationItem,
        onDismiss: () {
          _removeNotification(notificationItem);
        },
      ),
    );

    notificationItem.overlayEntry = overlayEntry;
    notificationItem.index = 0; // Thông báo mới ở vị trí 0

    _notifications.insert(0, notificationItem); // Thêm vào đầu danh sách
    overlay.insert(overlayEntry);

    // Tự động đóng sau 2.5 giây
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        _removeNotification(notificationItem);
      }
    });
  }

  static void _removeNotification(_NotificationItem item) {
    if (item.overlayEntry?.mounted == true) {
      item.overlayEntry!.remove();
    }
    final removedIndex = _notifications.indexOf(item);
    _notifications.remove(item);
    
    // Cập nhật lại index cho các thông báo phía sau
    for (int i = removedIndex; i < _notifications.length; i++) {
      _notifications[i].index = i;
    }
  }

  static double getTopPosition(int index) {
    return _topStart + (index * _notificationHeight);
  }
}

class _NotificationItem {
  OverlayEntry? overlayEntry;
  int index = 0;
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final _NotificationItem notificationItem;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.notificationItem,
    required this.onDismiss,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: SnackbarHelper.getTopPosition(widget.notificationItem.index),
      right: 16,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
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
                  color: widget.backgroundColor,
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
                    Icon(widget.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
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
    );
  }
}
