import 'package:flutter/material.dart';
import '../models/season.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';
import '../services/season_service.dart';
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
      // Xóa task khỏi danh sách sau khi lưu thành công
      setState(() {
        _tasks.removeWhere((t) => t.taskId == task.taskId);
      });
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã bỏ qua công việc này'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi bỏ qua công việc'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Đã xóa mùa vụ thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Quay về màn hình danh sách
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
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
        title: const Text('Chi tiết mùa vụ'),
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
      body: Column(
        children: [
          // Header - Chào bạn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Chào bạn,',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(now),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Mã mùa vụ
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang canh tác cho lô:',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.season.seasonName,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Nút xem truy xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xem kết quả truy xuất nguồn gốc',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'VIỆC CẦN LÀM HÔM NAY (${_tasks.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Danh sách công việc
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTasks,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có công việc!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Mùa vụ này chưa có kế hoạch canh tác.\nTạo nhật ký thủ công hoặc thêm kế hoạch.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                if (_currentDay != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      'Ngày thứ $_currentDay của mùa vụ',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MaterialSelectionScreen(
                                          seasonId: widget.season.id,
                                          seasonLocation: widget.season.farmArea,
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value == true) _loadTasks();
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tạo nhật ký thủ công'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              final icon = _getTaskIcon(index);
                              final color = _getTaskColor(index);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header công việc
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                      child: Row(
                                        children: [
                                          Text(
                                            icon,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              task.taskName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Đường kẻ ngăn cách
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Divider(
                                        height: 1,
                                        color: Colors.grey.shade200,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Thông tin
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('📍', style: TextStyle(fontSize: 16)),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Khu vực: ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                task.area ?? 'N/A',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Text('🕒', style: TextStyle(fontSize: 16)),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Thời gian: ${_getTaskDateRange(task)}${task.frequency == "Hàng ngày" ? " (Hàng ngày)" : ""}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Hiển thị ghi chú nếu có (ưu tiên cho manual log)
                                          if (task.notes != null && task.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.blue.shade200,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text('📝', style: TextStyle(fontSize: 14)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'Ghi chú: ${task.notes}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.blue.shade900,
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

                                    const SizedBox(height: 16),

                                    // Buttons
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _handleTaskComplete(task),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Xác nhận đã làm',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _handleTaskSkip(task),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.grey.shade700,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                side: BorderSide(color: Colors.grey.shade300),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Bỏ qua',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Đã thêm nhật ký thành công'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}