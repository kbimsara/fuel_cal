import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/vehicle.dart';
import 'models/fuel_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = join(dir, 'fuel_cal.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
    );
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        tank_capacity REAL NOT NULL,
        total_gauge_poles INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE fuel_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        km_reading REAL NOT NULL,
        current_gauge_poles INTEGER NOT NULL,
        liters_filled REAL,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Vehicles ──────────────────────────────────────────────────────────────

  Future<int> insertVehicle(Vehicle v) async =>
      (await database).insert('vehicles', v.toMap());

  Future<List<Vehicle>> getVehicles() async {
    final maps = await (await database).query('vehicles', orderBy: 'id ASC');
    return maps.map(Vehicle.fromMap).toList();
  }

  Future<void> updateVehicle(Vehicle v) async =>
      (await database).update('vehicles', v.toMap(),
          where: 'id = ?', whereArgs: [v.id]);

  Future<void> deleteVehicle(int id) async =>
      (await database).delete('vehicles', where: 'id = ?', whereArgs: [id]);

  // ── Fuel entries ──────────────────────────────────────────────────────────

  Future<int> insertEntry(FuelEntry e) async =>
      (await database).insert('fuel_entries', e.toMap());

  Future<List<FuelEntry>> getEntriesForVehicle(int vehicleId) async {
    final maps = await (await database).query(
      'fuel_entries',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'km_reading ASC, date ASC',
    );
    return maps.map(FuelEntry.fromMap).toList();
  }

  Future<void> updateEntry(FuelEntry e) async =>
      (await database).update('fuel_entries', e.toMap(),
          where: 'id = ?', whereArgs: [e.id]);

  Future<void> deleteEntry(int id) async =>
      (await database).delete('fuel_entries', where: 'id = ?', whereArgs: [id]);
}
