// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import '../models/daily_task.dart';

class TaskCard extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onQuickConfirm;
  final VoidCallback onDetailedLog;
  final VoidCallback onSkip;

  const TaskCard({
    super.key,
    required this.task,
    required this.onQuickConfirm,
    required this.onDetailedLog,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.task_alt, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tần suất: ${task.frequency}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (task.suggestedMaterials.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Vật tư gợi ý:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                ...task.suggestedMaterials.map((material) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '• ${material.materialName}: ${material.quantityPerUnit} ${material.unit}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onQuickConfirm,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Xong'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDetailedLog,
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Chi tiết'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onSkip,
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                    tooltip: 'Bỏ qua',
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}