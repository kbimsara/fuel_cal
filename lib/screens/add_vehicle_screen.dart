import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../theme.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? existing;
  const AddVehicleScreen({super.key, this.existing});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _tankCtrl = TextEditingController();
  final _polesCtrl = TextEditingController();

  static const _types = [
    'Car', 'Motorcycle', 'Truck', 'Van', 'SUV', 'Bus', 'Tuk-tuk'
  ];
  String _selectedType = 'Car';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final v = widget.existing!;
      _nameCtrl.text = v.name;
      _tankCtrl.text = v.tankCapacity.toString();
      _polesCtrl.text = v.totalGaugePoles.toString();
      _selectedType = v.type;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tankCtrl.dispose();
    _polesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Vehicle name
            _label('Vehicle Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. My Honda, Work Truck',
                prefixIcon:
                    Icon(Icons.badge_rounded, color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter vehicle name';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Vehicle type
            _label('Vehicle Type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((type) {
                final selected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_vehicleIcon(type),
                            size: 16,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(type,
                            style: TextStyle(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Tank capacity
            _label('Tank Capacity'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tankCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(
                hintText: 'e.g. 45',
                prefixIcon: Icon(Icons.local_gas_station_rounded,
                    color: AppTheme.textSecondary),
                suffixText: 'Liters',
                helperText: 'Maximum fuel the tank can hold',
                helperStyle:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter tank capacity';
                final val = double.tryParse(v);
                if (val == null || val <= 0) return 'Enter a valid capacity';
                if (val > 2000) return 'Capacity seems too large';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Gauge poles
            _label('Total Fuel Gauge Poles'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _polesCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'e.g. 8',
                prefixIcon:
                    Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
                helperText:
                    'Number of indicator segments on your physical gauge (usually 4, 6, 8, or 16)',
                helperStyle:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                helperMaxLines: 2,
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter number of poles';
                final val = int.tryParse(v);
                if (val == null || val < 2) return 'Minimum 2 poles';
                if (val > 32) return 'Maximum 32 poles';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Preset pole buttons
            Row(
              children: [4, 6, 8, 10, 16].map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _polesCtrl.text = p.toString()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(
                          color: _polesCtrl.text == p.toString()
                              ? AppTheme.primary
                              : AppTheme.border),
                    ),
                    child: Text('$p',
                        style: TextStyle(
                            color: _polesCtrl.text == p.toString()
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : Text(isEdit ? 'Save Changes' : 'Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final vp = context.read<VehicleProvider>();
    final vehicle = Vehicle(
      id: widget.existing?.id,
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      tankCapacity: double.parse(_tankCtrl.text.trim()),
      totalGaugePoles: int.parse(_polesCtrl.text.trim()),
    );

    if (widget.existing != null) {
      await vp.update(vehicle);
    } else {
      await vp.add(vehicle);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  IconData _vehicleIcon(String type) {
    switch (type) {
      case 'Motorcycle':
        return Icons.two_wheeler_rounded;
      case 'Truck':
        return Icons.local_shipping_rounded;
      case 'Van':
        return Icons.airport_shuttle_rounded;
      case 'Bus':
        return Icons.directions_bus_rounded;
      case 'SUV':
        return Icons.directions_car_filled_rounded;
      case 'Tuk-tuk':
        return Icons.electric_rickshaw_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
