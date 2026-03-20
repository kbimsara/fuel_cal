import 'package:flutter/foundation.dart';
import '../database_helper.dart';
import '../models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  Vehicle? _selected;
  bool _loading = false;

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selected => _selected;
  bool get loading => _loading;

  /// Called when a vehicle is selected; used to load its entries.
  void Function(Vehicle?)? onVehicleSelected;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    _vehicles = await DatabaseHelper.instance.getVehicles();
    if (_vehicles.isNotEmpty) {
      _selected = _vehicles.first;
      onVehicleSelected?.call(_selected);
    }
    _loading = false;
    notifyListeners();
  }

  void select(Vehicle v) {
    _selected = v;
    onVehicleSelected?.call(v);
    notifyListeners();
  }

  Future<void> add(Vehicle v) async {
    final id = await DatabaseHelper.instance.insertVehicle(v);
    final created = v.copyWith(id: id);
    _vehicles.add(created);
    if (_selected == null) {
      _selected = created;
      onVehicleSelected?.call(created);
    }
    notifyListeners();
  }

  Future<void> update(Vehicle v) async {
    await DatabaseHelper.instance.updateVehicle(v);
    final idx = _vehicles.indexWhere((e) => e.id == v.id);
    if (idx != -1) _vehicles[idx] = v;
    if (_selected?.id == v.id) {
      _selected = v;
      onVehicleSelected?.call(v);
    }
    notifyListeners();
  }

  Future<void> delete(Vehicle v) async {
    await DatabaseHelper.instance.deleteVehicle(v.id!);
    _vehicles.removeWhere((e) => e.id == v.id);
    if (_selected?.id == v.id) {
      _selected = _vehicles.isNotEmpty ? _vehicles.first : null;
      onVehicleSelected?.call(_selected);
    }
    notifyListeners();
  }
}
