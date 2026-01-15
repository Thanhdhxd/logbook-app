// lib/domain/entities/task_entity.dart

/// Domain Entity - Daily Task
class TaskEntity {
  final String taskId;
  final String taskName;
  final String frequency;
  final List<SuggestedMaterialEntity> suggestedMaterials;
  final List<UsedMaterialEntity> usedMaterials;
  final String? area;
  final String status;
  final String? notes;
  final DateTime? completedAt;

  const TaskEntity({
    required this.taskId,
    required this.taskName,
    required this.frequency,
    required this.suggestedMaterials,
    this.usedMaterials = const [],
    this.area,
    required this.status,
    this.notes,
    this.completedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isDone => status == 'DONE';
  bool get isSkipped => status == 'SKIPPED';
}

/// Domain Entity - Suggested Material
class SuggestedMaterialEntity {
  final String materialName;
  final double quantityPerUnit;
  final String unit;

  const SuggestedMaterialEntity({
    required this.materialName,
    required this.quantityPerUnit,
    required this.unit,
  });
}

/// Domain Entity - Used Material
class UsedMaterialEntity {
  final String materialName;
  final double quantity;
  final String unit;

  const UsedMaterialEntity({
    required this.materialName,
    required this.quantity,
    required this.unit,
  });
}
