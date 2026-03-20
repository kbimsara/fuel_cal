class Vehicle {
  final int? id;
  final String name;
  final String type;
  final double tankCapacity;
  final int totalGaugePoles;

  const Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.tankCapacity,
    required this.totalGaugePoles,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'tank_capacity': tankCapacity,
        'total_gauge_poles': totalGaugePoles,
      };

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'] as int,
        name: m['name'] as String,
        type: m['type'] as String,
        tankCapacity: (m['tank_capacity'] as num).toDouble(),
        totalGaugePoles: m['total_gauge_poles'] as int,
      );

  Vehicle copyWith({
    int? id,
    String? name,
    String? type,
    double? tankCapacity,
    int? totalGaugePoles,
  }) =>
      Vehicle(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        tankCapacity: tankCapacity ?? this.tankCapacity,
        totalGaugePoles: totalGaugePoles ?? this.totalGaugePoles,
      );
}
