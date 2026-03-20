import 'dart:math';
import 'package:flutter/material.dart';

class FuelGaugeWidget extends StatelessWidget {
  final int totalPoles;
  final int currentPoles;
  final double tankCapacity;
  final double size;

  const FuelGaugeWidget({
    super.key,
    required this.totalPoles,
    required this.currentPoles,
    required this.tankCapacity,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = totalPoles > 0
        ? (currentPoles / totalPoles).clamp(0.0, 1.0)
        : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: ratio),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size * 0.75,
        child: CustomPaint(
          painter: _GaugePainter(
            totalPoles: totalPoles,
            currentPoles: currentPoles,
            fillRatio: value,
            tankCapacity: tankCapacity,
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int totalPoles;
  final int currentPoles;
  final double fillRatio;
  final double tankCapacity;

  // Arc: starts at 8 o'clock (lower-left), sweeps 240° clockwise to 4 o'clock (lower-right)
  // Flutter canvas: 0° = 3 o'clock (right), clockwise positive
  // 150° in Flutter = 8 o'clock position (lower-left) ✓
  // 150° + 240° = 390° = 30° = 4 o'clock (lower-right) ✓
  static const double _startDeg = 150;
  static const double _sweepDeg = 240;

  const _GaugePainter({
    required this.totalPoles,
    required this.currentPoles,
    required this.fillRatio,
    required this.tankCapacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // center near bottom-center so gauge arc fills upper portion
    final center = Offset(size.width / 2, size.height * 0.62);
    final radius = size.width * 0.38;
    const trackW = 18.0;

    final startRad = _startDeg * pi / 180;
    final sweepRad = _sweepDeg * pi / 180;
    final rect = Rect.fromCircle(center: center, radius: radius);

    _drawBackground(canvas, rect, startRad, sweepRad, trackW);
    if (fillRatio > 0.01) {
      _drawFilled(canvas, rect, center, radius, startRad, sweepRad, trackW);
    }
    _drawTicks(canvas, center, radius, trackW, startRad, sweepRad);
    _drawEFLabels(canvas, center, radius, startRad, startRad + sweepRad);
    _drawCenterText(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Rect rect, double start, double sweep,
      double trackW) {
    canvas.drawArc(
      rect, start, sweep, false,
      Paint()
        ..color = const Color(0xFF1E2640)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawFilled(Canvas canvas, Rect rect, Offset center, double radius,
      double startRad, double sweepRad, double trackW) {
    final filledSweep = sweepRad * fillRatio;
    final color = _levelColor(fillRatio);

    // Glow layer
    canvas.drawArc(
      rect, startRad, filledSweep, false,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW + 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Main filled arc
    canvas.drawArc(
      rect, startRad, filledSweep, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW
        ..strokeCap = StrokeCap.round,
    );

    // Tip indicator
    final tipAngle = startRad + filledSweep;
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY), 8,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(tipX, tipY), 5,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  void _drawTicks(Canvas canvas, Offset c, double r, double trackW,
      double startRad, double sweepRad) {
    if (totalPoles <= 0) return;
    final inner = r - trackW / 2 - 5;
    final outer = r + trackW / 2 + 5;
    for (int i = 0; i <= totalPoles; i++) {
      final angle = startRad + sweepRad * i / totalPoles;
      final p1 = Offset(c.dx + inner * cos(angle), c.dy + inner * sin(angle));
      final p2 = Offset(c.dx + outer * cos(angle), c.dy + outer * sin(angle));
      canvas.drawLine(
        p1, p2,
        Paint()
          ..color = i <= currentPoles
              ? Colors.white.withValues(alpha: 0.45)
              : const Color(0xFF2D3A5C)
          ..strokeWidth = i == 0 || i == totalPoles ? 2.0 : 1.5,
      );
    }
  }

  void _drawEFLabels(Canvas canvas, Offset c, double r, double startRad,
      double endRad) {
    const off = 24.0;
    final ePos =
        Offset(c.dx + (r + off) * cos(startRad), c.dy + (r + off) * sin(startRad));
    final fPos =
        Offset(c.dx + (r + off) * cos(endRad), c.dy + (r + off) * sin(endRad));
    _text(canvas, 'E', ePos, const Color(0xFFFF4444), 14, FontWeight.bold);
    _text(canvas, 'F', fPos, const Color(0xFF00E676), 14, FontWeight.bold);
  }

  void _drawCenterText(Canvas canvas, Offset c, double r) {
    final pct = (fillRatio * 100).round();
    final liters = fillRatio * tankCapacity;
    final baseY = c.dy - r * 0.22;

    _text(canvas, '$pct%', Offset(c.dx, baseY - 18),
        Colors.white, 34, FontWeight.bold);
    _text(canvas, '${liters.toStringAsFixed(1)} L',
        Offset(c.dx, baseY + 22), const Color(0xFF00C8FF), 15,
        FontWeight.w600);
    _text(canvas, '$currentPoles / $totalPoles poles',
        Offset(c.dx, baseY + 44), const Color(0xFF8B95B0), 11,
        FontWeight.normal);
  }

  Color _levelColor(double r) {
    if (r <= 0.25) {
      return Color.lerp(const Color(0xFFFF1744), const Color(0xFFFF6B00),
          r / 0.25)!;
    } else if (r <= 0.5) {
      return Color.lerp(const Color(0xFFFF6B00), const Color(0xFFFFD600),
          (r - 0.25) / 0.25)!;
    } else {
      return Color.lerp(const Color(0xFFFFD600), const Color(0xFF00E676),
          (r - 0.5) / 0.5)!;
    }
  }

  void _text(Canvas canvas, String t, Offset pos, Color color, double size,
      FontWeight fw) {
    final tp = TextPainter(
      text: TextSpan(
          text: t,
          style: TextStyle(color: color, fontSize: size, fontWeight: fw)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fillRatio != fillRatio || old.currentPoles != currentPoles;
}
