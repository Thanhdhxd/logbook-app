// lib/domain/entities/material_entity.dart

/// Domain Entity - Material (Vật tư)
class MaterialEntity {
  final String id;
  final String materialName;
  final String category;
  final String? barcode;
  final String unit;

  const MaterialEntity({
    required this.id,
    required this.materialName,
    required this.category,
    this.barcode,
    required this.unit,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaterialEntity &&
        other.id == id &&
        other.materialName == materialName &&
        other.category == category &&
        other.barcode == barcode &&
        other.unit == unit;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      materialName.hashCode ^
      category.hashCode ^
      (barcode?.hashCode ?? 0) ^
      unit.hashCode;
}
