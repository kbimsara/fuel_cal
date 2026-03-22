import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_entry_provider.dart';
import '../models/fuel_entry.dart';
import '../models/trip_stat.dart';
import '../theme.dart';
import 'log_entry_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VehicleProvider, FuelEntryProvider>(
      builder: (context, vp, fp, _) {
        final vehicle = vp.selected;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Fuel History'),
            actions: [
              if (fp.entries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${fp.entries.length} entries',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
          body: vehicle == null
              ? _empty('No vehicle selected', 'Add a vehicle to start')
              : fp.entries.isEmpty
                  ? _empty(
                      'No entries yet',
                      'Use Log Entry tab to record your first reading')
                  : Column(
                      children: [
                        _summaryBar(fp),
                        Expanded(
                          child: _list(context, fp, vehicle.totalGaugePoles,
                              vehicle.tankCapacity),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _summaryBar(FuelEntryProvider fp) {
    final totalKm = fp.entries.length >= 2
        ? fp.entries.last.kmReading - fp.entries.first.kmReading
        : 0.0;
    final totalFuel =
        fp.stats.fold<double>(0, (sum, s) => sum + s.fuelConsumed);
    final avg = fp.avgKmPerLiter;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _sumItem(Icons.route_rounded,
              '${totalKm.toStringAsFixed(0)} km', 'Total km', AppTheme.primary),
          _divider(),
          _sumItem(Icons.water_drop_rounded,
              '${totalFuel.toStringAsFixed(1)} L', 'Total fuel', AppTheme.secondary),
          _divider(),
          _sumItem(Icons.speed_rounded,
              avg > 0 ? '${avg.toStringAsFixed(1)} km/L' : '--',
              'Avg efficiency', AppTheme.success),
        ],
      ),
    );
  }

  Widget _sumItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 32, color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _empty(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, FuelEntryProvider fp, int totalPoles,
      double tankCapacity) {
    // fp.entries is sorted ascending by km; show newest first
    final sorted = fp.entries; // ascending
    final entries = sorted.reversed.toList();
    final statByEntryId = {
      for (final s in fp.stats) s.entry.id: s,
    };

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final stat = statByEntryId[entry.id];
        // Find position in sorted list to derive prev/next km bounds
        final sortedIdx = sorted.indexOf(entry);
        final prevKm =
            sortedIdx > 0 ? sorted[sortedIdx - 1].kmReading : null;
        final nextKm =
            sortedIdx < sorted.length - 1
                ? sorted[sortedIdx + 1].kmReading
                : null;
        return _entryCard(context, entry, stat, totalPoles, tankCapacity, fp,
            prevKm, nextKm);
      },
    );
  }

  Widget _entryCard(
      BuildContext context,
      FuelEntry entry,
      TripStat? stat,
      int totalPoles,
      double tankCapacity,
      FuelEntryProvider fp,
      double? prevKm,
      double? nextKm) {
    final fraction =
        totalPoles > 0 ? (entry.currentGaugePoles / totalPoles) : 0.0;
    final liters = fraction * tankCapacity;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.danger),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => fp.deleteEntry(entry.id!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDate(entry.date),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                if (entry.litersFilled != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_gas_station_rounded,
                            size: 12, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text(
                          '+${entry.litersFilled!.toStringAsFixed(1)} L',
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  '${entry.kmReading.toStringAsFixed(0)} km',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogEntryScreen(
                        initialEntry: entry,
                        prevKm: prevKm,
                        nextKm: nextKm,
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_rounded,
                        size: 16, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Gauge bar + stats
            Row(
              children: [
                // Mini fuel bar
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.currentGaugePoles}/$totalPoles poles',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11),
                          ),
                          Text(
                            '${liters.toStringAsFixed(1)} L',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction.clamp(0.0, 1.0),
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _levelColor(fraction)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                if (stat != null) ...[
                  const SizedBox(width: 16),
                  // Trip stats
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        _miniStat(Icons.route_rounded,
                            '${stat.kmRun.toStringAsFixed(0)}km', 'Trip'),
                        _miniStat(Icons.opacity_rounded,
                            '${stat.fuelConsumed.toStringAsFixed(1)}L', 'Used'),
                        _miniStat(Icons.bolt_rounded,
                            stat.kmPerLiter.toStringAsFixed(1), 'km/L'),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.notes!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Color _levelColor(double r) {
    if (r <= 0.25) return AppTheme.danger;
    if (r <= 0.5) return AppTheme.orange;
    if (r <= 0.75) return AppTheme.warning;
    return AppTheme.success;
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Entry',
                style: TextStyle(color: AppTheme.textPrimary)),
            content: const Text(
                'This will permanently remove this entry and recalculate consumption statistics.',
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
        ) ??
        false;
  }
}
