import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_entry_provider.dart';
import '../models/fuel_entry.dart';
import '../models/vehicle.dart';
import '../theme.dart';
import '../widgets/gauge_poles_stepper.dart';

class LogEntryScreen extends StatefulWidget {
  const LogEntryScreen({super.key});

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  int _currentPoles = 0;
  bool _filledUp = false;
  bool _saving = false;

  @override
  void dispose() {
    _kmCtrl.dispose();
    _litersCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VehicleProvider, FuelEntryProvider>(
      builder: (context, vp, fp, _) {
        final vehicle = vp.selected;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Log Fuel Entry'),
            actions: [
              if (vehicle != null)
                TextButton.icon(
                  onPressed: _saving ? null : () => _save(context, vp, fp),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.primary))
                      : const Icon(Icons.check_rounded,
                          color: AppTheme.primary),
                  label: const Text('SAVE',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          body: vehicle == null
              ? _noVehicle()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    children: [
                      // Vehicle info banner
                      _vehicleBanner(vehicle),
                      const SizedBox(height: 20),

                      // Date
                      _label('Date'),
                      const SizedBox(height: 6),
                      _datePicker(),
                      const SizedBox(height: 16),

                      // Odometer
                      _label('Odometer Reading (km)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _kmCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'))
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 12500',
                          prefixIcon: Icon(Icons.speed_rounded,
                              color: AppTheme.textSecondary),
                          suffixText: 'km',
                        ),
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter odometer reading';
                          }
                          final km = double.tryParse(v);
                          if (km == null || km < 0) {
                            return 'Enter a valid number';
                          }
                          final prev = fp.latest?.kmReading;
                          if (prev != null && km <= prev) {
                            return 'Must be greater than last reading (${prev.toStringAsFixed(0)} km)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gauge poles stepper
                      GaugePolesStepper(
                        value: _currentPoles,
                        max: vehicle.totalGaugePoles,
                        onChanged: (v) => setState(() => _currentPoles = v),
                      ),
                      const SizedBox(height: 16),

                      // Fill up toggle
                      _filledUpToggle(),
                      if (_filledUp) ...[
                        const SizedBox(height: 16),
                        _label('Liters Filled'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _litersCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'))
                          ],
                          decoration: InputDecoration(
                            hintText: 'e.g. 35.0',
                            prefixIcon: const Icon(
                                Icons.local_gas_station_rounded,
                                color: AppTheme.textSecondary),
                            suffixText: 'L',
                            helperText:
                                'Tank capacity: ${vehicle.tankCapacity.toStringAsFixed(0)} L',
                            helperStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11),
                          ),
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          validator: (v) {
                            if (!_filledUp) return null;
                            if (v == null || v.isEmpty) {
                              return 'Enter liters filled';
                            }
                            final l = double.tryParse(v);
                            if (l == null || l <= 0) {
                              return 'Enter a valid amount';
                            }
                            if (l > vehicle.tankCapacity * 1.1) {
                              return 'Cannot exceed tank capacity';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Notes
                      _label('Notes (optional)'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Any remarks...',
                          prefixIcon: Icon(Icons.notes_rounded,
                              color: AppTheme.textSecondary),
                        ),
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed:
                            _saving ? null : () => _save(context, vp, fp),
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black))
                            : const Icon(Icons.save_rounded),
                        label: const Text('Save Entry'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _noVehicle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No vehicle selected',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Go to Vehicles tab to add your first vehicle',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _vehicleBanner(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_rounded,
              color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(
                    '${vehicle.type} · ${vehicle.tankCapacity.toStringAsFixed(0)}L tank · ${vehicle.totalGaugePoles} poles',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMMM yyyy').format(_date),
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _filledUpToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station_rounded,
              color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filled up fuel?',
                    style: TextStyle(
                        color: AppTheme.textPrimary, fontSize: 15)),
                Text('Toggle if you refueled today',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _filledUp,
            onChanged: (v) => setState(() {
              _filledUp = v;
              if (!v) _litersCtrl.clear();
            }),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(BuildContext context, VehicleProvider vp,
      FuelEntryProvider fp) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final entry = FuelEntry(
      vehicleId: vp.selected!.id!,
      date: DateFormat('yyyy-MM-dd').format(_date),
      kmReading: double.parse(_kmCtrl.text.trim()),
      currentGaugePoles: _currentPoles,
      litersFilled:
          _filledUp && _litersCtrl.text.isNotEmpty
              ? double.parse(_litersCtrl.text.trim())
              : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final ok = await fp.addEntry(entry);
    setState(() => _saving = false);

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.success),
              SizedBox(width: 8),
              Text('Entry saved successfully'),
            ],
          ),
        ),
      );
      _reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odometer must be greater than previous entry'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _kmCtrl.clear();
    _litersCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _date = DateTime.now();
      _currentPoles = 0;
      _filledUp = false;
    });
  }
}
