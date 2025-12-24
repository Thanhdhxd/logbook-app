// lib/screens/create_template_screen.dart
import 'package:flutter/material.dart';
import '../models/plan_template.dart';
import '../services/template_service.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _templateService = TemplateService();
  
  final _templateNameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  
  final List<Stage> _stages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _templateNameController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  void _addStage() {
    showDialog(
      context: context,
      builder: (context) {
        String stageName = '';
        
        return AlertDialog(
          title: const Text('Thêm giai đoạn'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên giai đoạn *',
              hintText: 'VD: Làm đất, Gieo sạ',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => stageName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (stageName.isNotEmpty) {
                  // Tự động tính ngày bắt đầu và kết thúc
                  int startDay = 1;
                  int endDay = 10;
                  
                  if (_stages.isNotEmpty) {
                    // Giai đoạn mới bắt đầu sau giai đoạn cuối cùng
                    final lastStage = _stages.last;
                    startDay = lastStage.endDay + 1;
                    endDay = startDay + 9; // Mỗi giai đoạn mặc định 10 ngày
                  }
                  
                  setState(() {
                    _stages.add(Stage(
                      stageName: stageName,
                      startDay: startDay,
                      endDay: endDay,
                      tasks: [],
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa giai đoạn ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _stages.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _addTask(int stageIndex) {
    showDialog(
      context: context,
      builder: (context) {
        String taskName = '';
        String frequency = 'Một lần';
        DateTime? selectedDate;
        String materialSuggestion = '';
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm công việc'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Tên công việc *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => taskName = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tần suất',
                        hintText: 'VD: Hàng ngày, 2 lần/tuần, 3 ngày/lần',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => frequency = value.isEmpty ? 'Một lần' : value,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Colors.green),
                      title: const Text('Ngày dự kiến'),
                      subtitle: Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Chọn ngày',
                        style: TextStyle(
                          fontWeight: selectedDate != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Vật tư gợi ý',
                        hintText: 'VD: Vôi bột, Phân lân',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => materialSuggestion = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskName.isNotEmpty) {
                      final materials = materialSuggestion.isEmpty 
                          ? <SuggestedMaterial>[]
                          : materialSuggestion.split(',').map((m) {
                              return SuggestedMaterial(
                                materialName: m.trim(),
                                suggestedQuantityUnit: null,
                              );
                            }).toList();
                      
                      final scheduledDateStr = selectedDate != null
                          ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                          : null;
                      
                      this.setState(() {
                        _stages[stageIndex].tasks.add(Task(
                          taskName: taskName,
                          frequency: frequency,
                          scheduledDate: scheduledDateStr,
                          suggestedMaterials: materials,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(int stageIndex, int taskIndex) {
    setState(() {
      _stages[stageIndex].tasks.removeAt(taskIndex);
    });
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_stages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 giai đoạn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final template = PlanTemplate(
        id: '',
        templateName: _templateNameController.text,
        cropType: _cropTypeController.text,
        durationDays: null,
        stages: _stages,
      );

      await _templateService.createTemplate(template);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Đã tạo kế hoạch thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo kế hoạch mới', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.save, size: 28, color: Colors.white),
              label: const Text(
                'Lưu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Thông tin cơ bản
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin cơ bản',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _templateNameController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: 'Tên kế hoạch *',
                        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment, size: 28),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên kế hoạch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _cropTypeController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: 'Loại cây trồng *',
                        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.eco, size: 28),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập loại cây trồng';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Header giai đoạn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline, color: Colors.blue, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Giai đoạn',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _addStage,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text('Thêm giai đoạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),

            // Danh sách giai đoạn
            if (_stages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Chưa có giai đoạn nào.\nNhấn "Thêm giai đoạn" để bắt đầu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            else
              ..._stages.asMap().entries.map((entry) {
                final stageIndex = entry.key;
                final stage = entry.value;
                return _buildStageCard(stage, stageIndex);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(Stage stage, int stageIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header giai đoạn
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Giai đoạn ${stageIndex + 1}: ${stage.stageName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                  onPressed: () => _deleteStage(stageIndex),
                  tooltip: 'Xóa giai đoạn',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            // Danh sách công việc
            if (stage.tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Chưa có công việc nào',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ...stage.tasks.asMap().entries.map((taskEntry) {
                final taskIndex = taskEntry.key;
                final task = taskEntry.value;
                return _buildTaskItem(task, stageIndex, taskIndex);
              }),
            const SizedBox(height: 12),
            // Nút thêm công việc
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addTask(stageIndex),
                icon: const Icon(Icons.add, size: 24),
                label: const Text('Thêm công việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, int stageIndex, int taskIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tần suất: ${task.frequency ?? "Một lần"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.suggestedMaterials.isEmpty
                      ? 'Vật tư gợi ý: (không)'
                      : 'Vật tư gợi ý: ${task.suggestedMaterials.map((m) => m.materialName).join(", ")}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 28, color: Colors.red),
            onPressed: () => _deleteTask(stageIndex, taskIndex),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Xóa',
          ),
        ],
      ),
    );
  }
}
