import 'package:flutter/material.dart';
import '../models/season.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';
import '../services/season_service.dart';
import '../utils/snackbar_helper.dart';
import 'material_selection_screen.dart';
import 'quick_confirm_screen.dart';
import 'traceability_screen.dart';
import 'template_management_screen.dart';

class SeasonDetailScreen extends StatefulWidget {
  final Season season;

  const SeasonDetailScreen({super.key, required this.season});

  @override
  State<SeasonDetailScreen> createState() => _SeasonDetailScreenState();
}

class _SeasonDetailScreenState extends State<SeasonDetailScreen> {
  final TaskService _taskService = TaskService();
  final SeasonService _seasonService = SeasonService();
  List<DailyTask> _tasks = [];
  int? _currentDay;
  String? _currentStage;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _taskService.getDailyTasks(widget.season.id);
      
      // API /api/seasons/daily/:seasonId đã trả về cả scheduled tasks và manual logs
      // Không cần gọi getManualLogs nữa để tránh duplicate
      final allTasks = data['tasks'] as List<DailyTask>;
      
      setState(() {
        _tasks = allTasks;
        _currentDay = data['currentDay'];
        _currentStage = data['currentStage'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTaskComplete(DailyTask task) async {
    // Mở màn hình xác nhận công việc cho tất cả các task
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickConfirmScreen(
          task: task,
          seasonId: widget.season.id,
          seasonLocation: widget.season.farmArea,
        ),
      ),
    );
    
    if (result == true && mounted) {
      // Hiện thông báo thành công
      SnackbarHelper.showSuccess(context, '✓ Đã xác nhận công việc thành công');
      
      // Reload tasks từ server để cập nhật danh sách
      await _loadTasks();
    }
  }

  Future<void> _handleTaskSkip(DailyTask task) async {
    // Bỏ qua = Ẩn task vĩnh viễn khỏi danh sách
    print('Bỏ qua task: ${task.taskName}');
    
    final success = await _taskService.hideTask(
      seasonId: widget.season.id,
      taskName: task.taskName,
      reason: 'SKIPPED',
    );
    
    print('hideTask result: $success');
    
    if (success && mounted) {
      // Xóa task khỏi danh sách
      setState(() {
        _tasks.removeWhere((t) => t.taskId == task.taskId);
      });
      
      SnackbarHelper.showInfo(
        context,
        'Đã bỏ qua công việc này',
      );
    } else if (mounted) {
      SnackbarHelper.showError(
        context,
        'Lỗi khi bỏ qua công việc',
      );
    }
  }

  String _getSeasonCode() {
    return widget.season.seasonName;
  }

  String _formatDate(DateTime date) {
    return 'Hôm nay, ngày ${date.day} tháng ${date.month}\n';
  }

  String _getTaskDateRange(DailyTask task) {
    final startDate = DateTime.now();
    final endDate = task.completedAt ?? DateTime.now();
    return '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')} - ${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}';
  }

  String _getTaskIcon(int index) {
    final icons = ['🟢', '🟡', '⚪', '🟠', '🔴'];
    return icons[index % icons.length];
  }

  Color _getTaskColor(int index) {
    final colors = [
      Colors.green,
      Colors.yellow.shade700,
      Colors.grey,
      Colors.orange,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Future<void> _confirmDeleteSeason() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa mùa vụ "${widget.season.seasonName}"?\n\n'
          'Tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _seasonService.deleteSeason(widget.season.id);
        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            '✓ Đã xóa mùa vụ thành công',
          );
          Navigator.pop(context, true); // Quay về màn hình danh sách
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Lỗi: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          widget.season.seasonName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'template') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TemplateManagementScreen(),
                  ),
                );
              } else if (value == 'delete') {
                _confirmDeleteSeason();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Quản lý kế hoạch'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa mùa vụ', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header - Chào bạn + nút truy xuất nguồn gốc trong cùng khung, tối ưu cho mobile
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.blue.shade100, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wb_sunny,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chào bạn,',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(now),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud, color: Colors.blue.shade400, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '28°C, Nắng',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TraceabilityScreen(
                              seasonId: widget.season.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search, size: 28),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      label: const Text(
                        'Xem kết quả truy xuất nguồn gốc',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

                       

                          // ...đã chuyển nút truy xuất vào khung header...

                          const SizedBox(height: 16),

                          // Tiêu đề danh sách (to, rõ ràng, tối ưu mobile)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Icon(Icons.list_alt, color: Colors.blue.shade700, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  'Việc cần làm hôm nay (${_tasks.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Danh sách công việc (tối ưu mobile)
                          if (_isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ))
                          else if (_errorMessage != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 40, color: Colors.red),
                                    const SizedBox(height: 12),
                                    Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _loadTasks,
                                      icon: const Icon(Icons.refresh, size: 26),
                                      label: const Text('Thử lại', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_tasks.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Chưa có công việc!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      child: Text(
                                        'Mùa vụ này chưa có kế hoạch canh tác.\nVui lòng thêm kế hoạch để bắt đầu.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                      ),
                                    ),
                                    if (_currentDay != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Ngày thứ $_currentDay của mùa vụ',
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              children: List.generate(_tasks.length, (index) {
                                final task = _tasks[index];
                                final icon = _getTaskIcon(index);
                                final color = _getTaskColor(index);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header công việc
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              icon,
                                              style: const TextStyle(fontSize: 22),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                task.taskName,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Đường kẻ ngăn cách
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Divider(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Thông tin
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text('📍', style: TextStyle(fontSize: 18)),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Khu vực: ',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  task.area ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Text('🕒', style: TextStyle(fontSize: 18)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Thời gian: ${_getTaskDateRange(task)}${task.frequency == "Hàng ngày" ? " (Hàng ngày)" : ""}',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Hiển thị ghi chú nếu có (ưu tiên cho manual log)
                                            if (task.notes != null && task.notes!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.blue.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Text('📝', style: TextStyle(fontSize: 18)),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        'Ghi chú: ${task.notes}',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Buttons
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _handleTaskComplete(task),
                                                icon: const Icon(Icons.check_circle, size: 26),
                                                label: const Text(
                                                  'Xác nhận',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green.shade700,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                                  elevation: 0,
                                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _handleTaskSkip(task),
                                                icon: const Icon(Icons.cancel, size: 26),
                                                label: const Text(
                                                  'Bỏ qua',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red.shade700,
                                                  side: BorderSide(color: Colors.red.shade200, width: 2),
                                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          const SizedBox(height: 60), // Để tránh FAB che mất nội dung cuối
                        ],
                      ),
                    ),
                    floatingActionButton: SizedBox(
                      height: 72,
                      width: 72,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaterialSelectionScreen(
                                seasonId: widget.season.id,
                                seasonLocation: widget.season.farmArea,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            // Reload danh sách công việc để hiển thị nhật ký mới
                            _loadTasks();
                            SnackbarHelper.showSuccess(
                              context,
                              '✓ Đã thêm nhật ký thành công',
                            );
                          }
                        },
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.add, size: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                        elevation: 4,
                      ),
                    ),
                  );
  }
}