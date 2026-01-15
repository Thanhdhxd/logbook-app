// lib/data/models/template_dto.dart

import '../../domain/entities/template_entity.dart';

class TemplateDTO {
  final String id;
  final String templateName;
  final String cropType;
  final int? durationDays;
  final List<StageDTO> stages;

  TemplateDTO({
    required this.id,
    required this.templateName,
    required this.cropType,
    this.durationDays,
    required this.stages,
  });

  factory TemplateDTO.fromJson(Map<String, dynamic> json) {
    return TemplateDTO(
      id: json['_id'] ?? '',
      templateName: json['templateName'] ?? '',
      cropType: json['cropType'] ?? '',
      durationDays: json['durationDays'],
      stages: (json['stages'] as List<dynamic>?)
              ?.map((stage) => StageDTO.fromJson(stage))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateName': templateName,
      'cropType': cropType,
      'durationDays': durationDays,
      'stages': stages.map((stage) => stage.toJson()).toList(),
    };
  }

  TemplateEntity toEntity() {
    return TemplateEntity(
      id: id,
      templateName: templateName,
      cropType: cropType,
      durationDays: durationDays,
      stages: stages.map((s) => s.toEntity()).toList(),
    );
  }

  factory TemplateDTO.fromEntity(TemplateEntity entity) {
    return TemplateDTO(
      id: entity.id,
      templateName: entity.templateName,
      cropType: entity.cropType,
      durationDays: entity.durationDays,
      stages: entity.stages.map((s) => StageDTO.fromEntity(s)).toList(),
    );
  }
}

class StageDTO {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<TemplateTaskDTO> tasks;

  StageDTO({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });

  factory StageDTO.fromJson(Map<String, dynamic> json) {
    return StageDTO(
      stageName: json['stageName'] ?? '',
      startDay: json['startDay'] ?? 0,
      endDay: json['endDay'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => TemplateTaskDTO.fromJson(task))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageName': stageName,
      'startDay': startDay,
      'endDay': endDay,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  StageEntity toEntity() {
    return StageEntity(
      stageName: stageName,
      startDay: startDay,
      endDay: endDay,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }

  factory StageDTO.fromEntity(StageEntity entity) {
    return StageDTO(
      stageName: entity.stageName,
      startDay: entity.startDay,
      endDay: entity.endDay,
      tasks: entity.tasks.map((t) => TemplateTaskDTO.fromEntity(t)).toList(),
    );
  }
}

class TemplateTaskDTO {
  final String taskName;
  final String? frequency;
  final String? scheduledDate;
  final List<TemplateMaterialDTO> suggestedMaterials;

  TemplateTaskDTO({
    required this.taskName,
    this.frequency,
    this.scheduledDate,
    required this.suggestedMaterials,
  });

  factory TemplateTaskDTO.fromJson(Map<String, dynamic> json) {
    return TemplateTaskDTO(
      taskName: json['taskName'] ?? '',
      frequency: json['frequency'],
      scheduledDate: json['scheduledDate'],
      suggestedMaterials: (json['suggestedMaterials'] as List<dynamic>?)
              ?.map((material) => TemplateMaterialDTO.fromJson(material))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'frequency': frequency,
      'scheduledDate': scheduledDate,
      'suggestedMaterials':
          suggestedMaterials.map((material) => material.toJson()).toList(),
    };
  }

  TemplateTaskEntity toEntity() {
    return TemplateTaskEntity(
      taskName: taskName,
      frequency: frequency,
      scheduledDate: scheduledDate,
      suggestedMaterials: suggestedMaterials.map((m) => m.toEntity()).toList(),
    );
  }

  factory TemplateTaskDTO.fromEntity(TemplateTaskEntity entity) {
    return TemplateTaskDTO(
      taskName: entity.taskName,
      frequency: entity.frequency,
      scheduledDate: entity.scheduledDate,
      suggestedMaterials:
          entity.suggestedMaterials.map((m) => TemplateMaterialDTO.fromEntity(m)).toList(),
    );
  }
}

class TemplateMaterialDTO {
  final String materialName;
  final String? suggestedQuantityUnit;

  TemplateMaterialDTO({
    required this.materialName,
    this.suggestedQuantityUnit,
  });

  factory TemplateMaterialDTO.fromJson(Map<String, dynamic> json) {
    return TemplateMaterialDTO(
      materialName: json['materialName'] ?? '',
      suggestedQuantityUnit: json['suggestedQuantityUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialName': materialName,
      'suggestedQuantityUnit': suggestedQuantityUnit,
    };
  }

  TemplateMaterialEntity toEntity() {
    return TemplateMaterialEntity(
      materialName: materialName,
      suggestedQuantityUnit: suggestedQuantityUnit,
    );
  }

  factory TemplateMaterialDTO.fromEntity(TemplateMaterialEntity entity) {
    return TemplateMaterialDTO(
      materialName: entity.materialName,
      suggestedQuantityUnit: entity.suggestedQuantityUnit,
    );
  }
}
