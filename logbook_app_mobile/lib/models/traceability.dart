// lib/models/traceability.dart

class TraceabilityData {
  final String lotCode;
  final String seasonName;
  final String farmArea;
  final DateTime startDate;
  final DateTime? harvestDate;
  final String templateName;
  final String cropType;
  final List<StageLog> stages;

  TraceabilityData({
    required this.lotCode,
    required this.seasonName,
    required this.farmArea,
    required this.startDate,
    this.harvestDate,
    required this.templateName,
    required this.cropType,
    required this.stages,
  });

  factory TraceabilityData.fromJson(Map<String, dynamic> json) {
    return TraceabilityData(
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
              ?.map((stage) => StageLog.fromJson(stage))
              .toList() ??
          [],
    );
  }
}

class StageLog {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<TaskLog> tasks;

  StageLog({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });

  factory StageLog.fromJson(Map<String, dynamic> json) {
    return StageLog(
      stageName: json['stageName'] ?? '',
      startDay: json['startDay'] ?? 0,
      endDay: json['endDay'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => TaskLog.fromJson(task))
              .toList() ??
          [],
    );
  }
}

class TaskLog {
  final String taskName;
  final bool? isCompleted; // Task đã hoàn thành chưa
  final List<DateTime> completedDates;
  final List<MaterialUsed> materials;
  final String notes;
  final String? scheduledDate; // Ngày dự kiến (DD/MM/YYYY)
  final List<SuggestedMaterial>? suggestedMaterials; // Vật tư đề xuất từ template

  TaskLog({
    required this.taskName,
    this.isCompleted,
    required this.completedDates,
    required this.materials,
    required this.notes,
    this.scheduledDate,
    this.suggestedMaterials,
  });

  factory TaskLog.fromJson(Map<String, dynamic> json) {
    return TaskLog(
      taskName: json['taskName'] ?? '',
      isCompleted: json['isCompleted'],
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
      materials: (json['materials'] as List<dynamic>?)
              ?.map((material) => MaterialUsed.fromJson(material))
              .toList() ??
          [],
      notes: json['notes'] ?? '',
      scheduledDate: json['scheduledDate'],
      suggestedMaterials: (json['suggestedMaterials'] as List<dynamic>?)
              ?.map((material) => SuggestedMaterial.fromJson(material))
              .toList(),
    );
  }
}

class MaterialUsed {
  final String materialName;
  final double quantity;
  final String unit;
  final String? barcode;

  MaterialUsed({
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.barcode,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) {
    return MaterialUsed(
      materialName: json['materialName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      barcode: json['barcode'],
    );
  }
}

class SuggestedMaterial {
  final String materialName;
  final String? suggestedQuantityUnit;

  SuggestedMaterial({
    required this.materialName,
    this.suggestedQuantityUnit,
  });

  factory SuggestedMaterial.fromJson(Map<String, dynamic> json) {
    return SuggestedMaterial(
      materialName: json['materialName'] ?? '',
      suggestedQuantityUnit: json['suggestedQuantityUnit'],
    );
  }
}
