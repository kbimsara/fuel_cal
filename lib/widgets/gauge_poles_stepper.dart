import 'package:flutter/material.dart';
import '../theme.dart';

class GaugePolesStepper extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const GaugePolesStepper({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Gauge Poles',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _btn(Icons.remove_rounded, () {
                    if (value > 0) onChanged(value - 1);
                  }, value == 0),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$value / $max',
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${(max > 0 ? value / max * 100 : 0).round()}% full',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _btn(Icons.add_rounded, () {
                    if (value < max) onChanged(value + 1);
                  }, value == max),
                ],
              ),
              const SizedBox(height: 12),
              // Visual pole indicator
              Row(
                children: List.generate(max, (i) {
                  final lit = i < value;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 8,
                      decoration: BoxDecoration(
                        color: lit ? _poleColor(value, max) : AppTheme.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? AppTheme.border.withValues(alpha: 0.3) : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon,
            color: disabled ? AppTheme.textSecondary : AppTheme.textPrimary,
            size: 22),
      ),
    );
  }

  Color _poleColor(int val, int max) {
    if (max == 0) return AppTheme.primary;
    final r = val / max;
    if (r <= 0.25) return AppTheme.danger;
    if (r <= 0.5) return AppTheme.orange;
    if (r <= 0.75) return AppTheme.warning;
    return AppTheme.success;
  }
}
