// lib/data/models/season_dto.dart

import '../../domain/entities/season_entity.dart';

/// Data Transfer Object for Season
class SeasonDTO {
  final String id;
  final String seasonName;
  final String? farmArea;
  final DateTime startDate;

  SeasonDTO({
    required this.id,
    required this.seasonName,
    this.farmArea,
    required this.startDate,
  });

  factory SeasonDTO.fromJson(Map<String, dynamic> json) {
    return SeasonDTO(
      id: json['_id'] as String,
      seasonName: json['seasonName'] as String,
      farmArea: json['farmArea']?.toString(),
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'seasonName': seasonName,
      'farmArea': farmArea,
      'startDate': startDate.toIso8601String(),
    };
  }

  SeasonEntity toEntity() {
    return SeasonEntity(
      id: id,
      seasonName: seasonName,
      farmArea: farmArea,
      startDate: startDate,
    );
  }

  factory SeasonDTO.fromEntity(SeasonEntity entity) {
    return SeasonDTO(
      id: entity.id,
      seasonName: entity.seasonName,
      farmArea: entity.farmArea,
      startDate: entity.startDate,
    );
  }
}
