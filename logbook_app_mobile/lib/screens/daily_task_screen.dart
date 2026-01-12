// lib/screens/daily_task_screen.dart
import 'package:flutter/material.dart';
import '../models/season.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../utils/snackbar_helper.dart';
import 'material_selection_screen.dart';

class DailyTaskScreen extends StatefulWidget {
  final Season season;

  const DailyTaskScreen({super.key, required this.season});

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  final TaskService _taskService = TaskService();
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
      
      // Loại bỏ duplicate tasks dựa trên taskId
      final List<DailyTask> allTasks = data['tasks'];
      final Map<String, DailyTask> uniqueTasksMap = {};
      
      for (var task in allTasks) {
        // Nếu đã có task này, chỉ giữ task có status DONE (manual log)
        if (uniqueTasksMap.containsKey(task.taskId)) {
          if (task.status == 'DONE') {
            uniqueTasksMap[task.taskId] = task;
          }
        } else {
          uniqueTasksMap[task.taskId] = task;
        }
      }
      
      // Hoặc deduplicate theo taskName nếu taskId giống nhau
      final Map<String, DailyTask> uniqueByName = {};
      for (var task in uniqueTasksMap.values) {
        final key = task.taskName.trim().toLowerCase();
        if (uniqueByName.containsKey(key)) {
          // Ưu tiên giữ task có status DONE
          if (task.status == 'DONE') {
            uniqueByName[key] = task;
          }
        } else {
          uniqueByName[key] = task;
        }
      }
      
      setState(() {
        _tasks = uniqueByName.values.toList();
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

  Future<void> _handleQuickConfirm(DailyTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hoàn thành'),
        content: Text('Bạn đã hoàn thành công việc "${task.taskName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _taskService.logTaskConfirmation(
        seasonId: widget.season.id,
        taskName: task.taskName,
        status: 'DONE',
      );

      if (success && mounted) {
        SnackbarHelper.showSuccess(context, 'Đã ghi nhật ký thành công! ✓');
        _loadTasks(); // Reload tasks
      }
    }
  }

  Future<void> _handleDetailedLog(DailyTask task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialSelectionScreen(
          task: task,
          seasonId: widget.season.id,
        ),
      ),
    );

    if (result == true && mounted) {
      // Reload tasks ngay lập tức khi quay về
      await _loadTasks();
    }
  }

  Future<void> _handleSkip(DailyTask task) async {
    final success = await _taskService.logTaskConfirmation(
      seasonId: widget.season.id,
      taskName: task.taskName,
      status: 'SKIPPED',
    );

    if (success && mounted) {
      SnackbarHelper.showInfo(context, 'Đã bỏ qua công việc');
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.season.seasonName),
            if (_currentStage != null)
              Text(
                _currentStage!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _buildBody(),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Mùa vụ này chưa có kế hoạch canh tác.\nVui lòng thêm kế hoạch để bắt đầu.',
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
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_currentDay != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Text(
              'Ngày thứ $_currentDay - ${_tasks.length} công việc cần làm',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return TaskCard(
                task: task,
                onQuickConfirm: () => _handleQuickConfirm(task),
                onDetailedLog: () => _handleDetailedLog(task),
                onSkip: () => _handleSkip(task),
              );
            },
          ),
        ),
      ],
    );
  }
}