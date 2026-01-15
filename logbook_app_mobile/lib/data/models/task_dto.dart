// lib/data/models/task_dto.dart

import '../../domain/entities/task_entity.dart';

class TaskDTO {
  final String taskId;
  final String taskName;
  final String frequency;
  final List<SuggestedMaterialDTO> suggestedMaterials;
  final List<UsedMaterialDTO> usedMaterials;
  final String? area;
  final String status;
  final String? notes;
  final DateTime? completedAt;

  TaskDTO({
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

  factory TaskDTO.fromJson(Map<String, dynamic> json) {
    return TaskDTO(
      taskId: json['taskId'] ?? '',
      taskName: json['taskName'] as String,
      frequency: json['frequency'] ?? '',
      suggestedMaterials: (json['suggestedMaterials'] as List?)
              ?.map((m) => SuggestedMaterialDTO.fromJson(m))
              .toList() ??
          [],
      usedMaterials: (json['usedMaterials'] as List?)
              ?.map((m) => UsedMaterialDTO.fromJson(m))
              .toList() ??
          [],
      area: json['area']?.toString(),
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      taskId: taskId,
      taskName: taskName,
      frequency: frequency,
      suggestedMaterials:
          suggestedMaterials.map((m) => m.toEntity()).toList(),
      usedMaterials: usedMaterials.map((m) => m.toEntity()).toList(),
      area: area,
      status: status,
      notes: notes,
      completedAt: completedAt,
    );
  }
}

class SuggestedMaterialDTO {
  final String materialName;
  final double quantityPerUnit;
  final String unit;

  SuggestedMaterialDTO({
    required this.materialName,
    required this.quantityPerUnit,
    required this.unit,
  });

  factory SuggestedMaterialDTO.fromJson(Map<String, dynamic> json) {
    return SuggestedMaterialDTO(
      materialName: json['materialName'] as String,
      quantityPerUnit: (json['quantityPerUnit'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  SuggestedMaterialEntity toEntity() {
    return SuggestedMaterialEntity(
      materialName: materialName,
      quantityPerUnit: quantityPerUnit,
      unit: unit,
    );
  }
}

class UsedMaterialDTO {
  final String materialName;
  final double quantity;
  final String unit;

  UsedMaterialDTO({
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  factory UsedMaterialDTO.fromJson(Map<String, dynamic> json) {
    return UsedMaterialDTO(
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  UsedMaterialEntity toEntity() {
    return UsedMaterialEntity(
      materialName: materialName,
      quantity: quantity,
      unit: unit,
    );
  }
}
