// lib/screens/daily_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/season_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import '../providers/service_providers.dart';
import '../widgets/task_card.dart';
import '../../utils/snackbar_helper.dart';
import 'material_selection_screen.dart';

class TaskEntityScreen extends ConsumerStatefulWidget {
  final SeasonEntity season;

  const TaskEntityScreen({super.key, required this.season});

  @override
  ConsumerState<TaskEntityScreen> createState() => _TaskEntityScreenState();
}

class _TaskEntityScreenState extends ConsumerState<TaskEntityScreen> {
  List<TaskEntity> _tasks = [];
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
      final getDailyTasks = ref.read(getDailyTasksUseCaseProvider);
      final allTasks = await getDailyTasks.execute(widget.season.id, DateTime.now());
      
      // Loại bỏ duplicate tasks dựa trên taskId
      final Map<String, TaskEntity> uniqueTasksMap = {};
      
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
      final Map<String, TaskEntity> uniqueByName = {};
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
        _currentDay = null; // API trả về tasks list, không có currentDay
        _currentStage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQuickConfirm(TaskEntity task) async {
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
      final taskService = ref.read(taskServiceProvider);
      final success = await taskService.logTaskConfirmation(
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

  Future<void> _handleDetailedLog(TaskEntity task) async {
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

  Future<void> _handleSkip(TaskEntity task) async {
    final logTaskUseCase = ref.read(logTaskUseCaseProvider);
    final success = await logTaskUseCase.execute(
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


