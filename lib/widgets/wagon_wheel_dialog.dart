import 'dart:math';
import 'package:flutter/material.dart';

class WagonWheelDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTapUp: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.globalPosition);
          final int index = _detectSegment(localOffset, box.size);
          if (index != -1) {
            Navigator.pop(context, index + 1);
          }
        },
        child: Container(
          width: 350,
          height: 350,
          child: CustomPaint(
            painter: WagonWheelPainter(),
          ),
        ),
      ),
    );
  }

  int _detectSegment(Offset point, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final angle = (atan2(dy, dx) + 2 * pi) % (2 * pi); // normalize 0 to 2π

    // Each segment is 45 degrees (π/4 radians)
    final segment = ((angle / (pi / 4)).floor()) % 8;

    return segment; // 0 to 7
  }
}

class WagonWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;

    // Ground
    final Paint circlePaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Segments
    final Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    for (int i = 0; i < 8; i++) {
      double angle = (pi / 4) * i;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), linePaint);
    }

    // Pitch
    const double pitchWidth = 17;
    const double pitchHeight = 60;
    final Rect pitchRect = Rect.fromCenter(
      center: center,
      width: pitchWidth,
      height: pitchHeight,
    );
    final Paint pitchPaint = Paint()
      ..color = Colors.brown[300]!
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    canvas.drawRect(pitchRect, pitchPaint);

    // Batsman dot at top of pitch
    const double batsmanDotRadius = 2;
    final Offset batsmanPosition = Offset(
      center.dx,
      center.dy -
          pitchHeight / 2 -
          batsmanDotRadius +
          8, // Slightly above the top of the pitch
    );
    final Paint batsmanPaint = Paint()
      ..color = Colors.white!
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal, 0.5); // Add subtle blur for depth

    // Draw shadow first
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(
        batsmanPosition.translate(0.5, 0.5), batsmanDotRadius, shadowPaint);

    // Draw the dot on top
    canvas.drawCircle(batsmanPosition, batsmanDotRadius, batsmanPaint);

    // Index Labels (1-8)
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 8; i++) {
      double angle = (pi / 4) * i + (pi / 8); // Center text within segment
      final double labelRadius = radius * 0.7; // Closer to center

      final Offset labelPos = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      final offset =
          labelPos - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
