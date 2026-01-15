// lib/data/models/material_dto.dart

import '../../domain/entities/material_entity.dart';

class MaterialDTO {
  final String id;
  final String materialName;
  final String category;
  final String? barcode;
  final String unit;

  MaterialDTO({
    required this.id,
    required this.materialName,
    required this.category,
    this.barcode,
    required this.unit,
  });

  factory MaterialDTO.fromJson(Map<String, dynamic> json) {
    return MaterialDTO(
      id: json['_id'] as String,
      materialName: json['materialName'] as String,
      category: json['category'] as String,
      barcode: json['barcode'],
      unit: json['unit'] as String,
    );
  }

  MaterialEntity toEntity() {
    return MaterialEntity(
      id: id,
      materialName: materialName,
      category: category,
      barcode: barcode,
      unit: unit,
    );
  }
}
