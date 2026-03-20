import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/trip_stat.dart';
import '../theme.dart';

class ConsumptionChart extends StatelessWidget {
  final List<TripStat> stats;

  const ConsumptionChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.length < 2) return const SizedBox.shrink();

    final recent = stats.length > 10 ? stats.sublist(stats.length - 10) : stats;
    final spots = recent
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), double.parse(e.value.kmPerLiter.toStringAsFixed(2))))
        .toList();

    final values = recent.map((s) => s.kmPerLiter).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.25;
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.75)
        .clamp(0.0, double.infinity);

    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 8),
            child: Text(
              'CONSUMPTION TREND  (km/L)',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.0),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: recent.length > 2,
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.success]),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: AppTheme.primary,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppTheme.border.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (v, m) => Text(
                        v.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= recent.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '#${stats.length - recent.length + i + 1}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} km/L',
                              const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
