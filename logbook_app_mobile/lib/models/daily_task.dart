// lib/models/daily_task.dart
class DailyTask {
  final String taskId;
  final String taskName;
  final String frequency;
  final List<SuggestedMaterial> suggestedMaterials;
  final List<UsedMaterial> usedMaterials;
  final String? area;
  final String status;
  final String? notes;
  final DateTime? completedAt;

  DailyTask({
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

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      taskId: json['taskId'] ?? '',
      taskName: json['taskName'],
      frequency: json['frequency'] ?? '',
      suggestedMaterials: (json['suggestedMaterials'] as List?)
              ?.map((m) => SuggestedMaterial.fromJson(m))
              .toList() ??
          [],
      usedMaterials: (json['usedMaterials'] as List?)
              ?.map((m) => UsedMaterial.fromJson(m))
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
}

class SuggestedMaterial {
  final String materialName;
  final double quantityPerUnit;
  final String unit;

  SuggestedMaterial({
    required this.materialName,
    required this.quantityPerUnit,
    required this.unit,
  });

  factory SuggestedMaterial.fromJson(Map<String, dynamic> json) {
    return SuggestedMaterial(
      materialName: json['materialName'],
      quantityPerUnit: json['quantityPerUnit']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }
}

class UsedMaterial {
  final String? materialId;
  final String materialName;
  final double quantity;
  final String unit;

  UsedMaterial({
    this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  factory UsedMaterial.fromJson(Map<String, dynamic> json) {
    return UsedMaterial(
      materialId: json['materialId'] ?? json['_id'],
      materialName: json['materialName'] ?? '',
      quantity: json['quantity']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }
}