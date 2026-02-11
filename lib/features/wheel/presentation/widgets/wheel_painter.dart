import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/wheel_slice.dart';
import '../../logic/wheel_math.dart';

class WheelPainter extends CustomPainter {
  const WheelPainter({required this.slices});

  final List<WheelSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(
      shadowPath,
      Colors.black.withValues(alpha: 0.45),
      20,
      false,
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    if (slices.isEmpty) {
      final emptyPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, emptyPaint);
      canvas.drawCircle(
        center,
        radius * 0.94,
        ringPaint..style = PaintingStyle.stroke,
      );
      return;
    }

    final sweep = WheelMath.sweepAngle(slices.length);
    final start = WheelMath.wheelStartAngle(slices.length);

    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final color = Color(slice.colorValue);
      final sliceStart = start + (i * sweep);

      final segmentPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.80),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        sliceStart,
        sweep,
        true,
        segmentPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        sliceStart,
        sweep,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.26),
      );

      _paintLabel(
        canvas,
        center,
        radius,
        slice.label,
        sliceStart + (sweep / 2),
      );
    }

    canvas.drawCircle(center, radius, ringPaint);

    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.2)),
    );

    _paintGloss(canvas, center, radius);
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double angle,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: math.max(11, radius * 0.08),
          fontWeight: FontWeight.w700,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: radius * 0.46);

    final labelRadius = radius * 0.62;
    final labelOffset = Offset(
      center.dx + math.cos(angle) * labelRadius,
      center.dy + math.sin(angle) * labelRadius,
    );

    canvas.save();
    canvas.translate(labelOffset.dx, labelOffset.dy);

    var textRotation = angle + math.pi / 2;
    final normalized = WheelMath.normalize(angle);
    if (normalized > math.pi / 2 && normalized < (math.pi * 1.5)) {
      textRotation += math.pi;
    }
    canvas.rotate(textRotation);

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  void _paintGloss(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final clip = Path()..addOval(rect);
    canvas.save();
    canvas.clipPath(clip);

    final glossRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.42),
      width: radius * 1.6,
      height: radius * 0.9,
    );

    canvas.drawOval(
      glossRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.36),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(glossRect),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
