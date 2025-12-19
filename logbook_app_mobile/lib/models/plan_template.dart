// lib/models/plan_template.dart

class PlanTemplate {
  final String id;
  final String templateName;
  final String cropType;
  final int? durationDays;
  final List<Stage> stages;

  PlanTemplate({
    required this.id,
    required this.templateName,
    required this.cropType,
    this.durationDays,
    required this.stages,
  });

  // Tính tổng số công việc
  int get totalTasks {
    int total = 0;
    for (var stage in stages) {
      total += stage.tasks.length;
    }
    return total;
  }

  factory PlanTemplate.fromJson(Map<String, dynamic> json) {
    return PlanTemplate(
      id: json['_id'] ?? '',
      templateName: json['templateName'] ?? '',
      cropType: json['cropType'] ?? '',
      durationDays: json['durationDays'],
      stages: (json['stages'] as List<dynamic>?)
              ?.map((stage) => Stage.fromJson(stage))
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
}

class Stage {
  final String stageName;
  final int startDay;
  final int endDay;
  final List<Task> tasks;

  Stage({
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.tasks,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stageName: json['stageName'] ?? '',
      startDay: json['startDay'] ?? 0,
      endDay: json['endDay'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(task))
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
}

class Task {
  final String taskName;
  final String? frequency;
  final String? scheduledDate; // Ngày dự kiến (DD/MM/YYYY)
  final List<SuggestedMaterial> suggestedMaterials;

  Task({
    required this.taskName,
    this.frequency,
    this.scheduledDate,
    required this.suggestedMaterials,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['taskName'] ?? '',
      frequency: json['frequency'],
      scheduledDate: json['scheduledDate'],
      suggestedMaterials: (json['suggestedMaterials'] as List<dynamic>?)
              ?.map((material) => SuggestedMaterial.fromJson(material))
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

  Map<String, dynamic> toJson() {
    return {
      'materialName': materialName,
      'suggestedQuantityUnit': suggestedQuantityUnit,
    };
  }
}
