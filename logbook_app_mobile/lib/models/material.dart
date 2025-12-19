// lib/models/material.dart
class Material {
  final String id;
  final String materialName;
  final String category;
  final String? barcode;
  final String unit;

  Material({
    required this.id,
    required this.materialName,
    required this.category,
    this.barcode,
    required this.unit,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['_id'],
      materialName: json['materialName'],
      category: json['category'],
      barcode: json['barcode'],
      unit: json['unit'],
    );
  }
}