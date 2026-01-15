// lib/presentation/screens/season_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/season_entity.dart';
import '../providers/season_providers.dart';
import '../providers/auth_providers.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../core/error/error_handler.dart';
import 'daily_task_screen.dart';
import 'create_season_screen.dart';
import 'season_detail_screen.dart';
import 'login_screen.dart';

class SeasonSelectionScreen extends ConsumerStatefulWidget {
  final bool showWelcomeMessage;
  
  const SeasonSelectionScreen({super.key, this.showWelcomeMessage = false});

  @override
  ConsumerState<SeasonSelectionScreen> createState() => _SeasonSelectionScreenState();
}

class _SeasonSelectionScreenState extends ConsumerState<SeasonSelectionScreen> {
  List<SeasonEntity> _seasons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
    
    // Hiển thị thông báo đăng nhập thành công nếu có
    if (widget.showWelcomeMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            'Đăng nhập thành công',
          );
        }
      });
    }
  }

  Future<void> _loadSeasons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await SecureStorageService.instance.getUserInfo();
      final userId = userInfo['userId'];
      
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final getSeasonsUseCase = ref.read(getSeasonsUseCaseProvider);
      final seasons = await getSeasonsUseCase.execute(userId);
      setState(() {
        _seasons = seasons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn Mùa Vụ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30),
            onPressed: _loadSeasons,
            tooltip: 'Làm mới',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 30),
            onSelected: (value) async {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
                _showUserProfile();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Thông tin tài khoản'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: SizedBox(
        width: 220,
        height: 64,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateSeasonScreen(),
              ),
            );
            // Nếu có kết quả trả về (Season object)
            if (result != null && mounted) {
              await _loadSeasons();
              if (mounted) {
                SnackbarHelper.showSuccess(
                  context,
                  'Tạo mùa vụ "${result.seasonName}" thành công! 🎉',
                );
              }
            }
          },
          icon: const Icon(Icons.add, size: 32),
          label: const Text(
            'Tạo Mùa Vụ Mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSeasons,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_seasons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có mùa vụ nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút bên dưới để tạo mùa vụ đầu tiên',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: _seasons.length,
      itemBuilder: (context, index) {
        final season = _seasons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 18),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeasonDetailScreen(season: season),
                ),
              );
              if (result == true && mounted) {
                _loadSeasons();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    radius: 32,
                    child: const Icon(Icons.grass, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.seasonName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vị trí: ${season.farmArea}',
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày bắt đầu: ${_formatDate(season.startDate)}',
                          style: const TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 32, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Xử lý đăng xuất
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase.execute();
      
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Hiển thị thông tin user
  Future<void> _showUserProfile() async {
    final userInfo = await SecureStorageService.instance.getUserInfo();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Thông tin tài khoản'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên:', userInfo['userName'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow('Email:', userInfo['userEmail'] ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}