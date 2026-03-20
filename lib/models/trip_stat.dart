import 'fuel_entry.dart';
import 'vehicle.dart';

class TripStat {
  final FuelEntry entry;
  final double kmRun;
  final double fuelConsumed; // liters
  final double kmPerLiter;
  final double lPer100km;

  const TripStat({
    required this.entry,
    required this.kmRun,
    required this.fuelConsumed,
    required this.kmPerLiter,
    required this.lPer100km,
  });

  /// Compute trip stats between two consecutive entries.
  /// Returns null if data is insufficient (zero km or zero fuel consumed).
  static TripStat? compute(
    FuelEntry prev,
    FuelEntry curr,
    Vehicle vehicle,
  ) {
    final kmRun = curr.kmReading - prev.kmReading;
    if (kmRun <= 0) return null;

    final prevFuel =
        (prev.currentGaugePoles / vehicle.totalGaugePoles) * vehicle.tankCapacity;
    final currFuel =
        (curr.currentGaugePoles / vehicle.totalGaugePoles) * vehicle.tankCapacity;
    final litersFilled = curr.litersFilled ?? 0.0;
    final fuelConsumed = prevFuel + litersFilled - currFuel;
    if (fuelConsumed <= 0) return null;

    final kmPerLiter = kmRun / fuelConsumed;
    return TripStat(
      entry: curr,
      kmRun: kmRun,
      fuelConsumed: fuelConsumed,
      kmPerLiter: kmPerLiter,
      lPer100km: 100.0 / kmPerLiter,
    );
  }
}
