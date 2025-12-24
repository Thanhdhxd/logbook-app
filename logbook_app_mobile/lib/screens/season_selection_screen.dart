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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tạo mùa vụ "${result.seasonName}" thành công! 🎉',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
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
}