import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/app_settings.dart';

class AnimatedFancyBackground extends StatefulWidget {
  const AnimatedFancyBackground({
    super.key,
    required this.intensity,
    required this.child,
  });

  final BackgroundIntensity intensity;
  final Widget child;

  @override
  State<AnimatedFancyBackground> createState() =>
      _AnimatedFancyBackgroundState();
}

class _AnimatedFancyBackgroundState extends State<AnimatedFancyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int particles;
    double amplitude;
    switch (widget.intensity) {
      case BackgroundIntensity.low:
        particles = 18;
        amplitude = 12;
      case BackgroundIntensity.medium:
        particles = 30;
        amplitude = 20;
      case BackgroundIntensity.high:
        particles = 44;
        amplitude = 30;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobPainter(
                  t: _controller.value,
                  isDark: isDark,
                  amplitude: amplitude,
                ),
              );
            },
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  t: _controller.value,
                  isDark: isDark,
                  count: particles,
                  drift: amplitude,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({
    required this.t,
    required this.isDark,
    required this.amplitude,
  });

  final double t;
  final bool isDark;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF0B1020),
              const Color(0xFF13203C),
              const Color(0xFF102A43),
            ]
          : [
              const Color(0xFFEAF3FF),
              const Color(0xFFF3F6FF),
              const Color(0xFFE7FFFB),
            ],
    );

    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = baseGradient.createShader(rect));

    final centers = [
      Offset(
        size.width * (0.2 + 0.05 * math.sin(t * math.pi * 2)),
        size.height * (0.22 + 0.04 * math.cos(t * math.pi * 2)),
      ),
      Offset(
        size.width * (0.84 + 0.06 * math.cos(t * math.pi * 2 + 1.4)),
        size.height * (0.18 + 0.08 * math.sin(t * math.pi * 2 + 1.4)),
      ),
      Offset(
        size.width * (0.52 + 0.07 * math.sin(t * math.pi * 2 + 2.2)),
        size.height * (0.86 + 0.05 * math.cos(t * math.pi * 2 + 2.2)),
      ),
    ];

    final colors = isDark
        ? [
            const Color(0xFF2563EB).withValues(alpha: 0.16),
            const Color(0xFF06B6D4).withValues(alpha: 0.16),
            const Color(0xFF60A5FA).withValues(alpha: 0.12),
          ]
        : [
            const Color(0xFF60A5FA).withValues(alpha: 0.20),
            const Color(0xFF22D3EE).withValues(alpha: 0.16),
            const Color(0xFF34D399).withValues(alpha: 0.12),
          ];

    for (var i = 0; i < centers.length; i++) {
      canvas.drawCircle(
        centers[i],
        size.shortestSide * (0.28 + i * 0.06) + amplitude,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
          ..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.isDark != isDark;
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.t,
    required this.isDark,
    required this.count,
    required this.drift,
  });

  final double t;
  final bool isDark;
  final int count;
  final double drift;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(321);
    for (var i = 0; i < count; i++) {
      final seed = i / count;
      final phase = t * math.pi * 2 + seed * 12;
      final x =
          (seed * size.width +
              math.sin(phase) * drift * 0.6 +
              random.nextDouble() * 12) %
          size.width;
      final y =
          ((seed * 1.8 * size.height) +
              math.cos(phase * 0.8) * drift +
              t * size.height * 0.15) %
          size.height;
      final radius = 1 + (math.sin(phase * 1.3).abs() * 2.8);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = (isDark ? Colors.white : Colors.black).withValues(
            alpha: isDark ? 0.12 : 0.06,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.count != count ||
        oldDelegate.drift != drift;
  }
}
