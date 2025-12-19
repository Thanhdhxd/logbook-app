// lib/models/season.dart
class Season {
  final String id;
  final String seasonName;
  final String? farmArea;
  final DateTime startDate;

  Season({
    required this.id,
    required this.seasonName,
    this.farmArea,
    required this.startDate,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['_id'],
      seasonName: json['seasonName'],
      farmArea: json['farmArea']?.toString() ?? 'N/A', // Chuyển thành String
      startDate: DateTime.parse(json['startDate']),
    );
  }
}