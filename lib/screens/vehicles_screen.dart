import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database_helper.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../theme.dart';
import 'add_vehicle_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vp, _) => Scaffold(
        appBar: AppBar(title: const Text('My Vehicles')),
        body: vp.vehicles.isEmpty
            ? _emptyState(context)
            : _vehicleList(context, vp),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addVehicle(context),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.garage_rounded,
                  size: 60, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text('No vehicles yet',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Add your first vehicle to start tracking fuel consumption',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _addVehicle(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleList(BuildContext context, VehicleProvider vp) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: vp.vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _vehicleCard(context, vp, vp.vehicles[i]),
    );
  }

  Widget _vehicleCard(
      BuildContext context, VehicleProvider vp, Vehicle v) {
    final isSelected = vp.selected?.id == v.id;
    return FutureBuilder<List>(
      future: DatabaseHelper.instance.getEntriesForVehicle(v.id!),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return _vehicleCardInner(context, vp, v, isSelected, count);
      },
    );
  }

  Widget _vehicleCardInner(BuildContext context, VehicleProvider vp,
      Vehicle v, bool isSelected, int entryCount) {
    return GestureDetector(
      onTap: () => vp.select(v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_vehicleIcon(v.type),
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  size: 26),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(v.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(v.type, AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      _badge(
                          '${v.tankCapacity.toStringAsFixed(0)}L tank',
                          AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      _badge('${v.totalGaugePoles} poles',
                          AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      _badge(
                          '$entryCount ${entryCount == 1 ? 'entry' : 'entries'}',
                          entryCount > 0 ? AppTheme.primary : AppTheme.textSecondary),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.border)),
              onSelected: (action) =>
                  _handleAction(context, action, v, vp),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 10),
                      Text('Edit',
                          style:
                              TextStyle(color: AppTheme.textPrimary)),
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded,
                          color: AppTheme.danger, size: 18),
                      SizedBox(width: 10),
                      Text('Delete',
                          style:
                              TextStyle(color: AppTheme.danger)),
                    ])),
              ],
              child: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Text(text,
        style: TextStyle(color: color, fontSize: 12));
  }

  Future<void> _addVehicle(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const AddVehicleScreen(), fullscreenDialog: true),
    );
  }

  Future<void> _handleAction(BuildContext context, String action,
      Vehicle v, VehicleProvider vp) async {
    if (action == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddVehicleScreen(existing: v),
            fullscreenDialog: true),
      );
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('Delete ${v.name}',
              style: const TextStyle(color: AppTheme.textPrimary)),
          content: const Text(
              'This will permanently delete this vehicle and all its fuel entries.',
              style: TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) vp.delete(v);
    }
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
