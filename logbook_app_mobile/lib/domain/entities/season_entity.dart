// lib/domain/entities/season_entity.dart

/// Domain Entity - Season (Mùa vụ)
/// Pure Dart class, framework-independent
class SeasonEntity {
  final String id;
  final String seasonName;
  final String? farmArea;
  final DateTime startDate;

  const SeasonEntity({
    required this.id,
    required this.seasonName,
    this.farmArea,
    required this.startDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonEntity &&
        other.id == id &&
        other.seasonName == seasonName &&
        other.farmArea == farmArea &&
        other.startDate == startDate;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      seasonName.hashCode ^
      (farmArea?.hashCode ?? 0) ^
      startDate.hashCode;

  @override
  String toString() =>
      'SeasonEntity(id: $id, name: $seasonName, area: $farmArea, startDate: $startDate)';
}
