// lib/domain/entities/traceability_entity.dart

/// Domain Entity - Traceability Data
class TraceabilityEntity {
  final String lotCode;
  final String seasonName;
  final String farmArea;
  final DateTime startDate;
  final DateTime? harvestDate;
  final String templateName;
  final String cropType;
  final List<StageLogEntity> stages;

  const TraceabilityEntity({
    required this.lotCode,
    required this.seasonName,
    required this.farmArea,
    required this.startDate,
    this.harvestDate,
    required this.templateName,
    required this.cropType,
    required this.stages,
  });
}

/// Domain Entity - Stage Log
class StageLogEntity {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<TaskLogEntity> tasks;

  const StageLogEntity({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });
}

/// Domain Entity - Task Log
class TaskLogEntity {
  final String taskName;
  final String status;
  final DateTime? completedAt;
  final String? notes;
  final List<MaterialUsedEntity> usedMaterials;

  const TaskLogEntity({
    required this.taskName,
    required this.status,
    this.completedAt,
    this.notes,
    required this.usedMaterials,
  });
}

/// Domain Entity - Material Used
class MaterialUsedEntity {
  final String materialName;
  final double quantity;
  final String unit;

  const MaterialUsedEntity({
    required this.materialName,
    required this.quantity,
    required this.unit,
  });
}
