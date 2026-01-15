// lib/data/models/traceability_dto.dart

import '../../domain/entities/traceability_entity.dart';

class TraceabilityDTO {
  final String lotCode;
  final String seasonName;
  final String farmArea;
  final DateTime startDate;
  final DateTime? harvestDate;
  final String templateName;
  final String cropType;
  final List<StageLogDTO> stages;

  TraceabilityDTO({
    required this.lotCode,
    required this.seasonName,
    required this.farmArea,
    required this.startDate,
    this.harvestDate,
    required this.templateName,
    required this.cropType,
    required this.stages,
  });

  factory TraceabilityDTO.fromJson(Map<String, dynamic> json) {
    return TraceabilityDTO(
      lotCode: json['lotCode'] ?? '',
      seasonName: json['seasonName'] ?? '',
      farmArea: json['farmArea'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'])
          : null,
      templateName: json['templateName'] ?? '',
      cropType: json['cropType'] ?? '',
      stages: (json['stages'] as List<dynamic>?)
              ?.map((stage) => StageLogDTO.fromJson(stage))
              .toList() ??
          [],
    );
  }

  TraceabilityEntity toEntity() {
    return TraceabilityEntity(
      lotCode: lotCode,
      seasonName: seasonName,
      farmArea: farmArea,
      startDate: startDate,
      harvestDate: harvestDate,
      templateName: templateName,
      cropType: cropType,
      stages: stages.map((s) => s.toEntity()).toList(),
    );
  }
}

class StageLogDTO {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<TaskLogDTO> tasks;

  StageLogDTO({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });

  factory StageLogDTO.fromJson(Map<String, dynamic> json) {
    return StageLogDTO(
      stageName: json['stageName'] ?? '',
      startDay: json['startDay'] ?? 0,
      endDay: json['endDay'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => TaskLogDTO.fromJson(task))
              .toList() ??
          [],
    );
  }

  StageLogEntity toEntity() {
    return StageLogEntity(
      stageName: stageName,
      startDay: startDay,
      endDay: endDay,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }
}

class TaskLogDTO {
  final String taskName;
  final String status;
  final DateTime? completedAt;
  final String? notes;
  final List<MaterialUsedDTO> usedMaterials;

  TaskLogDTO({
    required this.taskName,
    required this.status,
    this.completedAt,
    this.notes,
    required this.usedMaterials,
  });

  factory TaskLogDTO.fromJson(Map<String, dynamic> json) {
    // API returns: isCompleted, completedDates, materials, notes, scheduledDate, suggestedMaterials
    final isCompleted = json['isCompleted'] ?? false;
    final completedDates = json['completedDates'] as List<dynamic>? ?? [];
    final notes = json['notes'] ?? '';
    
    return TaskLogDTO(
      taskName: json['taskName'] ?? '',
      status: isCompleted ? 'DONE' : 'TODO',
      completedAt: completedDates.isNotEmpty
          ? DateTime.parse(completedDates.last)
          : null,
      notes: notes.isEmpty ? null : notes,
      usedMaterials: (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialUsedDTO.fromJson(m))
              .toList() ??
          [],
    );
  }

  TaskLogEntity toEntity() {
    return TaskLogEntity(
      taskName: taskName,
      status: status,
      completedAt: completedAt,
      notes: notes,
      usedMaterials: usedMaterials.map((m) => m.toEntity()).toList(),
    );
  }
}

class MaterialUsedDTO {
  final String materialName;
  final double quantity;
  final String unit;

  MaterialUsedDTO({
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  factory MaterialUsedDTO.fromJson(Map<String, dynamic> json) {
    return MaterialUsedDTO(
      materialName: json['materialName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }

  MaterialUsedEntity toEntity() {
    return MaterialUsedEntity(
      materialName: materialName,
      quantity: quantity,
      unit: unit,
    );
  }
}
