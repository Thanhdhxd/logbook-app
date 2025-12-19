// lib/screens/template_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/plan_template.dart';
import '../services/template_service.dart';

class TemplateDetailScreen extends StatefulWidget {
  final PlanTemplate template;

  const TemplateDetailScreen({super.key, required this.template});

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  final TemplateService _templateService = TemplateService();
  late PlanTemplate _template;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _template = widget.template;
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _templateService.updateTemplate(_template.id, _template);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Đã lưu kế hoạch'),
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
                  
                  if (_template.stages.isNotEmpty) {
                    // Giai đoạn mới bắt đầu sau giai đoạn cuối cùng
                    final lastStage = _template.stages.last;
                    startDay = lastStage.endDay + 1;
                    endDay = startDay + 9; // Mỗi giai đoạn mặc định 10 ngày
                  }
                  
                  setState(() {
                    _template.stages.add(Stage(
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
                _template.stages.removeAt(index);
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
                        _template.stages[stageIndex].tasks.add(Task(
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
      _template.stages[stageIndex].tasks.removeAt(taskIndex);
    });
  }

  void _editTask(int stageIndex, int taskIndex) {
    final task = _template.stages[stageIndex].tasks[taskIndex];
    
    showDialog(
      context: context,
      builder: (context) {
        String taskName = task.taskName;
        String frequency = task.frequency ?? 'Một lần';
        DateTime? selectedDate;
        
        // Parse scheduledDate nếu có
        if (task.scheduledDate != null && task.scheduledDate!.isNotEmpty) {
          try {
            final parts = task.scheduledDate!.split('/');
            if (parts.length == 3) {
              selectedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          } catch (e) {
            // Ignore parse error
          }
        }
        
        String materialSuggestion = task.suggestedMaterials
            .map((m) => m.materialName)
            .join(', ');
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa công việc'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: taskName,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Tên công việc *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => taskName = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: frequency,
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
                    TextFormField(
                      initialValue: materialSuggestion,
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
                        _template.stages[stageIndex].tasks[taskIndex] = Task(
                          taskName: taskName,
                          frequency: frequency,
                          scheduledDate: scheduledDateStr,
                          suggestedMaterials: materials,
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết kế hoạch'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveTemplate,
              child: const Text(
                'Lưu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thông tin cơ bản
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin cơ bản',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tên kế hoạch', _template.templateName),
                    const SizedBox(height: 12),
                    _buildInfoRow('Loại cây trồng', _template.cropType),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header giai đoạn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giai đoạn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addStage,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm giai đoạn'),
                ),
              ],
            ),

            // Danh sách giai đoạn
            ..._template.stages.asMap().entries.map((entry) {
              final stageIndex = entry.key;
              final stage = entry.value;
              return _buildStageCard(stage, stageIndex);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStageCard(Stage stage, int stageIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header giai đoạn
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Giai đoạn ${stageIndex + 1}: ${stage.stageName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteStage(stageIndex),
                ),
              ],
            ),
            
            const Divider(),
            
            const SizedBox(height: 8),

            // Danh sách công việc
            if (stage.tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Chưa có công việc nào',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...stage.tasks.asMap().entries.map((taskEntry) {
                final taskIndex = taskEntry.key;
                final task = taskEntry.value;
                return _buildTaskItem(task, stageIndex, taskIndex);
              }),

            const SizedBox(height: 8),

            // Nút thêm công việc
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addTask(stageIndex),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm công việc'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.suggestedMaterials.isEmpty
                      ? 'Vật tư gợi ý: (không)'
                      : 'Vật tư gợi ý: ${task.suggestedMaterials.map((m) => m.materialName).join(", ")}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: () => _editTask(stageIndex, taskIndex),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.red),
                onPressed: () => _deleteTask(stageIndex, taskIndex),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
