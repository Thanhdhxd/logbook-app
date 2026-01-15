// lib/presentation/screens/template_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/template_entity.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/template_providers.dart';
import '../../utils/snackbar_helper.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  final TemplateEntity template;

  const TemplateDetailScreen({super.key, required this.template});

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  late TemplateEntity _template;
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
      final updateTemplate = ref.read(updateTemplateUseCaseProvider);
      await updateTemplate(_template.id, _template);
      
      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '✓ Đã lưu kế hoạch',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Lỗi: $e',
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
                if (stageName.isEmpty) {
                  SnackbarHelper.showWarning(context, 'Cần nhập tên giai đoạn');
                  return;
                }
                
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
                  _template.stages.add(StageEntity(
                    stageName: stageName,
                    startDay: startDay,
                    endDay: endDay,
                    tasks: [],
                  ));
                });
                Navigator.pop(context);
                SnackbarHelper.showSuccess(this.context, 'Đã thêm giai đoạn "$stageName"');
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
              final stageName = _template.stages[index].stageName;
              setState(() {
                _template.stages.removeAt(index);
              });
              Navigator.pop(context);
              SnackbarHelper.showInfo(this.context, 'Đã xóa giai đoạn "$stageName"');
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
                    if (taskName.isEmpty) {
                      SnackbarHelper.showWarning(context, 'Cần nhập tên công việc');
                      return;
                    }
                    
                    final materials = materialSuggestion.isEmpty 
                        ? <TemplateMaterialEntity>[]
                        : materialSuggestion.split(',').map((m) {
                            return TemplateMaterialEntity(
                              materialName: m.trim(),
                              suggestedQuantityUnit: null,
                            );
                          }).toList();
                    
                    final scheduledDateStr = selectedDate != null
                        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                        : null;
                    
                    this.setState(() {
                      _template.stages[stageIndex].tasks.add(TemplateTaskEntity(
                        taskName: taskName,
                        frequency: frequency,
                        scheduledDate: scheduledDateStr,
                        suggestedMaterials: materials,
                      ));
                    });
                    Navigator.pop(context);
                    SnackbarHelper.showSuccess(this.context, 'Đã thêm công việc "$taskName"');
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
    final taskName = _template.stages[stageIndex].tasks[taskIndex].taskName;
    setState(() {
      _template.stages[stageIndex].tasks.removeAt(taskIndex);
    });
    SnackbarHelper.showInfo(context, 'Đã xóa công việc "$taskName"');
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
                          ? <TemplateMaterialEntity>[]
                          : materialSuggestion.split(',').map((m) {
                              return TemplateMaterialEntity(
                                materialName: m.trim(),
                                suggestedQuantityUnit: null,
                              );
                            }).toList();
                      
                      final scheduledDateStr = selectedDate != null
                          ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                          : null;
                      
                      this.setState(() {
                        _template.stages[stageIndex].tasks[taskIndex] = TemplateTaskEntity(
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
        title: const Text('Chi tiết kế hoạch', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    _buildInfoRow('Tên kế hoạch', _template.templateName, fontSize: 18),
                    const SizedBox(height: 14),
                    _buildInfoRow('Loại cây trồng', _template.cropType, fontSize: 18),
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

  Widget _buildInfoRow(String label, String value, {double fontSize = 16}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize - 2,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStageCard(StageEntity stage, int stageIndex) {
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

  Widget _buildTaskItem(TemplateTaskEntity task, int stageIndex, int taskIndex) {
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
                  task.suggestedMaterials.isEmpty
                      ? 'Vật tư gợi ý: (không)'
                      : 'Vật tư gợi ý: ${task.suggestedMaterials.map((m) => m.materialName).join(", ")}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 28, color: Colors.blue),
                onPressed: () => _editTask(stageIndex, taskIndex),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Chỉnh sửa',
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.close, size: 28, color: Colors.red),
                onPressed: () => _deleteTask(stageIndex, taskIndex),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

