import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_entry_provider.dart';
import '../models/vehicle.dart';
import '../theme.dart';
import '../widgets/fuel_gauge_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/consumption_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VehicleProvider, FuelEntryProvider>(
      builder: (context, vp, fp, _) {
        if (vp.loading || fp.loading) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }
        if (vp.selected == null) return _emptyState(context);
        return _dashboard(context, vp, fp);
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _emptyState(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with glow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(Icons.local_gas_station_rounded,
                      size: 44, color: AppTheme.primary),
                ),
                const SizedBox(height: 28),
                const Text('Welcome to FuelIQ',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  'Track your vehicle fuel consumption\nand save money smartly',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.success]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Your Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.background,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main dashboard ─────────────────────────────────────────────────────────

  Widget _dashboard(
      BuildContext context, VehicleProvider vp, FuelEntryProvider fp) {
    final vehicle = vp.selected!;
    final latest = fp.latest;
    final currentPoles = latest?.currentGaugePoles ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            titleSpacing: 16,
            title: GestureDetector(
              onTap: () => _showVehiclePicker(context, vp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(_vehicleIcon(vehicle.type), color: AppTheme.primary, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vehicle.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Text(vehicle.type,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                  if (vp.vehicles.length > 1) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded,
                        size: 16, color: AppTheme.textSecondary),
                  ],
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    Text(
                      DateFormat('d MMM').format(DateTime.now()),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _gaugeCard(context, vehicle, currentPoles, latest?.kmReading, fp),
                const SizedBox(height: 14),
                _statsRow(fp, vehicle),
                const SizedBox(height: 14),
                if (fp.stats.length >= 2) ...[
                  ConsumptionChart(stats: fp.stats),
                  const SizedBox(height: 14),
                ],
                if (latest != null) _lastEntryCard(latest, vehicle, fp),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gauge card ─────────────────────────────────────────────────────────────

  Widget _gaugeCard(BuildContext context, Vehicle vehicle, int currentPoles,
      double? kmReading, FuelEntryProvider fp) {
    final fraction = fp.currentFuelFraction;
    final statusColor = _levelColor(fraction);
    final statusText = _levelText(fraction);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        gradient: LinearGradient(
          colors: [AppTheme.card, const Color(0xFF1A2035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                const Text('FUEL LEVEL',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                if (kmReading != null)
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${kmReading.toStringAsFixed(0)} km',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Gauge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FuelGaugeWidget(
              totalPoles: vehicle.totalGaugePoles,
              currentPoles: currentPoles,
              tankCapacity: vehicle.tankCapacity,
              size: MediaQuery.of(context).size.width - 64,
            ),
          ),

          // Status bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: statusColor.withValues(alpha: 0.5),
                              blurRadius: 6)
                        ])),
                const SizedBox(width: 8),
                Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${(fraction * 100).round()}%  ·  ${fp.currentFuelLevel.toStringAsFixed(1)} L',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _statsRow(FuelEntryProvider fp, Vehicle vehicle) {
    final avg = fp.avgKmPerLiter;
    final range = fp.estimatedRange;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.speed_rounded,
            label: 'Avg Consumption',
            value: avg > 0 ? avg.toStringAsFixed(1) : '--',
            unit: 'km/L',
            accentColor: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.route_rounded,
            label: 'Est. Range',
            value: range > 0 ? range.toStringAsFixed(0) : '--',
            unit: 'km',
            accentColor: AppTheme.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.local_gas_station_rounded,
            label: 'Tank',
            value: vehicle.tankCapacity.toStringAsFixed(0),
            unit: 'L',
            accentColor: AppTheme.warning,
          ),
        ),
      ],
    );
  }

  // ── Last entry card ────────────────────────────────────────────────────────

  Widget _lastEntryCard(latest, Vehicle vehicle, FuelEntryProvider fp) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                const Text('LAST ENTRY',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  _formatDate(latest.date),
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1),
          ),

          // Odometer + fill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _infoChip(Icons.speed_rounded,
                    '${latest.kmReading.toStringAsFixed(0)} km', 'Odometer'),
                const SizedBox(width: 10),
                if (latest.litersFilled != null)
                  _infoChip(Icons.local_gas_station_rounded,
                      '+${latest.litersFilled!.toStringAsFixed(1)} L',
                      'Filled',
                      color: AppTheme.success),
                if (fp.stats.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  _infoChip(Icons.bolt_rounded,
                      '${fp.stats.last.kmPerLiter.toStringAsFixed(1)} km/L',
                      'Last trip',
                      color: AppTheme.primary),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String value, String label,
      {Color? color}) {
    final c = color ?? AppTheme.textSecondary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    color: color ?? AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Vehicle picker ─────────────────────────────────────────────────────────

  void _showVehiclePicker(BuildContext context, VehicleProvider vp) {
    if (vp.vehicles.length <= 1) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Switch Vehicle',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...vp.vehicles.map((v) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_vehicleIcon(v.type),
                      color: AppTheme.primary, size: 18),
                ),
                title: Text(v.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${v.type} · ${v.tankCapacity.toStringAsFixed(0)}L · ${v.totalGaugePoles} poles',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                trailing: vp.selected?.id == v.id
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primary)
                    : null,
                onTap: () {
                  vp.select(v);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Color _levelColor(double r) {
    if (r < 0.1) return AppTheme.danger;
    if (r < 0.25) return AppTheme.orange;
    if (r < 0.5) return AppTheme.warning;
    if (r < 0.75) return AppTheme.primary;
    return AppTheme.success;
  }

  String _levelText(double r) {
    if (r < 0.1) return 'Critical — Refuel Immediately!';
    if (r < 0.25) return 'Low — Refuel Soon';
    if (r < 0.5) return 'Getting Low';
    if (r < 0.75) return 'Moderate Level';
    return 'Good Level';
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
