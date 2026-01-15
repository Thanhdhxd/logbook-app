// lib/domain/entities/template_entity.dart

/// Domain Entity - Plan Template
class TemplateEntity {
  final String id;
  final String templateName;
  final String cropType;
  final int? durationDays;
  final List<StageEntity> stages;

  const TemplateEntity({
    required this.id,
    required this.templateName,
    required this.cropType,
    this.durationDays,
    required this.stages,
  });

  int get totalTasks {
    return stages.fold(0, (sum, stage) => sum + stage.tasks.length);
  }
}

/// Domain Entity - Stage
class StageEntity {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<TemplateTaskEntity> tasks;

  const StageEntity({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });
}

/// Domain Entity - Template Task
class TemplateTaskEntity {
  final String taskName;
  final String? frequency;
  final String? scheduledDate;
  final List<TemplateMaterialEntity> suggestedMaterials;

  const TemplateTaskEntity({
    required this.taskName,
    this.frequency,
    this.scheduledDate,
    required this.suggestedMaterials,
  });
}

/// Domain Entity - Template Suggested Material
class TemplateMaterialEntity {
  final String materialName;
  final String? suggestedQuantityUnit;

  const TemplateMaterialEntity({
    required this.materialName,
    this.suggestedQuantityUnit,
  });
}
