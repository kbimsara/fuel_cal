import 'package:flutter/foundation.dart';
import '../database_helper.dart';
import '../models/fuel_entry.dart';
import '../models/trip_stat.dart';
import '../models/vehicle.dart';

class FuelEntryProvider extends ChangeNotifier {
  List<FuelEntry> _entries = [];
  List<TripStat> _stats = [];
  Vehicle? _vehicle;
  bool _loading = false;

  List<FuelEntry> get entries => _entries;
  List<TripStat> get stats => _stats;
  bool get loading => _loading;

  FuelEntry? get latest => _entries.isNotEmpty ? _entries.last : null;

  // ── Computed dashboard values ─────────────────────────────────────────────

  double get currentFuelLevel {
    if (_vehicle == null || latest == null) return 0;
    return (latest!.currentGaugePoles / _vehicle!.totalGaugePoles) *
        _vehicle!.tankCapacity;
  }

  double get currentFuelFraction {
    if (_vehicle == null || latest == null) return 0;
    return (latest!.currentGaugePoles / _vehicle!.totalGaugePoles)
        .clamp(0.0, 1.0);
  }

  double get avgKmPerLiter {
    if (_stats.isEmpty) return 0;
    return _stats.map((s) => s.kmPerLiter).reduce((a, b) => a + b) /
        _stats.length;
  }

  double get estimatedRange {
    if (avgKmPerLiter <= 0) return 0;
    return currentFuelLevel * avgKmPerLiter;
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> loadForVehicle(Vehicle? vehicle) async {
    _vehicle = vehicle;
    _entries = [];
    _stats = [];
    if (vehicle == null) {
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    _entries =
        await DatabaseHelper.instance.getEntriesForVehicle(vehicle.id!);
    _rebuildStats();
    _loading = false;
    notifyListeners();
  }

  void _rebuildStats() {
    _stats = [];
    if (_vehicle == null) return;
    for (int i = 1; i < _entries.length; i++) {
      final s = TripStat.compute(_entries[i - 1], _entries[i], _vehicle!);
      if (s != null) _stats.add(s);
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<bool> addEntry(FuelEntry e) async {
    // Validate km is greater than previous entry
    if (latest != null && e.kmReading <= latest!.kmReading) {
      return false;
    }
    final id = await DatabaseHelper.instance.insertEntry(e);
    _entries.add(FuelEntry(
      id: id,
      vehicleId: e.vehicleId,
      date: e.date,
      kmReading: e.kmReading,
      currentGaugePoles: e.currentGaugePoles,
      litersFilled: e.litersFilled,
      notes: e.notes,
    ));
    _entries.sort((a, b) => a.kmReading.compareTo(b.kmReading));
    _rebuildStats();
    notifyListeners();
    return true;
  }

  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    _rebuildStats();
    notifyListeners();
  }
}
