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
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt, color: Colors.green, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    task.taskName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tần suất: ${task.frequency}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (task.suggestedMaterials.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Vật tư gợi ý:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
              ),
              ...task.suggestedMaterials.map((material) => Padding(
                    padding: const EdgeInsets.only(left: 18, top: 6),
                    child: Text(
                      '• ${material.materialName}: ${material.quantityPerUnit} ${material.unit}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onQuickConfirm,
                    icon: const Icon(Icons.check, size: 28),
                    label: const Text('Xong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetailedLog,
                    icon: const Icon(Icons.edit_note, size: 28),
                    label: const Text('Chi tiết', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onSkip,
                  icon: const Icon(Icons.close, size: 32),
                  color: Colors.red,
                  tooltip: 'Bỏ qua',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}