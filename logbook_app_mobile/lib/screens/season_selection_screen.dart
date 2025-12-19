// lib/screens/season_selection_screen.dart
import 'package:flutter/material.dart';
import '../models/season.dart';
import '../services/season_service.dart';
import 'daily_task_screen.dart';
import 'create_season_screen.dart';
import 'season_detail_screen.dart';

class SeasonSelectionScreen extends StatefulWidget {
  const SeasonSelectionScreen({super.key});

  @override
  State<SeasonSelectionScreen> createState() => _SeasonSelectionScreenState();
}

class _SeasonSelectionScreenState extends State<SeasonSelectionScreen> {
  final SeasonService _seasonService = SeasonService();
  List<Season> _seasons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final seasons = await _seasonService.getUserSeasons();
      setState(() {
        _seasons = seasons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Mùa Vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSeasons,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateSeasonScreen(),
            ),
          );
          
          // Nếu có kết quả trả về (Season object)
          if (result != null && mounted) {
            // Reload danh sách mùa vụ
            await _loadSeasons();
            
            // Hiển thị thông báo thành công
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tạo mùa vụ "${result.seasonName}" thành công! 🎉',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo Mùa Vụ Mới'),
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
      padding: const EdgeInsets.all(16),
      itemCount: _seasons.length,
      itemBuilder: (context, index) {
        final season = _seasons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.grass, color: Colors.white),
            ),
            title: Text(
              season.seasonName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Vị trí: ${season.farmArea}\n'
              'Ngày bắt đầu: ${_formatDate(season.startDate)}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeasonDetailScreen(season: season),
                ),
              );
              
              // Nếu có thay đổi (xóa mùa vụ), reload danh sách
              if (result == true && mounted) {
                _loadSeasons();
              }
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}