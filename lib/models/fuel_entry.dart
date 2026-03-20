class FuelEntry {
  final int? id;
  final int vehicleId;
  final String date; // ISO-8601 date string yyyy-MM-dd
  final double kmReading;
  final int currentGaugePoles;
  final double? litersFilled;
  final String? notes;

  const FuelEntry({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.kmReading,
    required this.currentGaugePoles,
    this.litersFilled,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'vehicle_id': vehicleId,
        'date': date,
        'km_reading': kmReading,
        'current_gauge_poles': currentGaugePoles,
        'liters_filled': litersFilled,
        'notes': notes,
      };

  factory FuelEntry.fromMap(Map<String, dynamic> m) => FuelEntry(
        id: m['id'] as int,
        vehicleId: m['vehicle_id'] as int,
        date: m['date'] as String,
        kmReading: (m['km_reading'] as num).toDouble(),
        currentGaugePoles: m['current_gauge_poles'] as int,
        litersFilled: m['liters_filled'] != null
            ? (m['liters_filled'] as num).toDouble()
            : null,
        notes: m['notes'] as String?,
      );
}
