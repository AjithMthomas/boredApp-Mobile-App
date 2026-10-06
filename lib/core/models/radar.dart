/// Radar zone aggregate model.
class RadarZoneData {
  const RadarZoneData({
    required this.zone,
    required this.free,
    required this.tasks,
    required this.tea,
    this.spot = '',
  });

  final String zone;
  final int free;
  final int tasks;
  final int tea;
  final String spot;

  factory RadarZoneData.fromJson(Map<String, dynamic> json) {
    return RadarZoneData(
      zone: json['zone'] as String? ?? '',
      free: (json['free'] as num?)?.toInt() ?? 0,
      tasks: (json['tasks'] as num?)?.toInt() ?? 0,
      tea: (json['tea'] as num?)?.toInt() ?? 0,
      spot: json['spot'] as String? ?? '',
    );
  }
}
