import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/wheel_slice.dart';
import '../../logic/wheel_math.dart';
import 'wheel_painter.dart';

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({
    super.key,
    required this.slices,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.speedLevel,
    required this.onResult,
    this.onSpinStateChanged,
  });

  final List<WheelSlice> slices;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final int speedLevel;
  final ValueChanged<int> onResult;
  final ValueChanged<bool>? onSpinStateChanged;

  @override
  State<SpinningWheel> createState() => SpinningWheelState();
}

class SpinningWheelState extends State<SpinningWheel>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _idleController;
  late final AnimationController _bounceController;

  bool _isSpinning = false;
  int _lastBoundary = -1;
  double _gestureVelocity = 0;
  double _lastPointerAngle = 0;
  Offset? _lastPointerPosition;
  Size _lastWheelSize = Size.zero;
  Duration? _lastPointerTime;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController.unbounded(vsync: this)
      ..addListener(_handleTickBoundary);
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _idleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  double get rotation => _rotationController.value;

  bool get isSpinning => _isSpinning;

  double get _speedT => ((widget.speedLevel.clamp(1, 10) - 1) / 9).toDouble();

  double get _buttonMinTurns => 3.0 + (19.0 * _speedT);

  double get _buttonMaxTurns => 4.2 + (24.0 * _speedT);

  int get _buttonSpinDurationMs => (3200 - (1700 * _speedT)).round();

  double get _gestureSpeedMultiplier {
    return 0.55 + (1.85 * _speedT);
  }

  double get _frictionCoefficient {
    return 0.25 - (0.16 * _speedT);
  }

  Future<void> spin({double? velocity}) async {
    if (_isSpinning || widget.slices.length < 2) {
      return;
    }

    final seed = math.Random();
    final initialVelocity = velocity ?? 0.0;
    if (velocity != null && initialVelocity.abs() < 0.1) {
      return;
    }

    _isSpinning = true;
    widget.onSpinStateChanged?.call(true);

    try {
      if (velocity == null) {
        final turns =
            _buttonMinTurns +
            seed.nextDouble() * (_buttonMaxTurns - _buttonMinTurns);
        final targetRotation =
            _rotationController.value + (turns * WheelMath.fullTurn);
        await _rotationController.animateTo(
          targetRotation,
          duration: Duration(milliseconds: _buttonSpinDurationMs),
          curve: Curves.easeOutQuart,
        );
      } else {
        final simulation = FrictionSimulation(
          _frictionCoefficient,
          _rotationController.value,
          initialVelocity,
          tolerance: Tolerance(
            velocity: 0.3,
            distance: WheelMath.sweepAngle(widget.slices.length) * 0.04,
          ),
        );
        await _rotationController.animateWith(simulation);
      }
      await _playStopBounce();
      if (!mounted) {
        return;
      }

      final winner = WheelMath.winnerIndex(
        sliceCount: widget.slices.length,
        rotation: _rotationController.value,
      );
      widget.onResult(winner);
    } finally {
      _isSpinning = false;
      widget.onSpinStateChanged?.call(false);
    }
  }

  Future<void> _playStopBounce() async {
    await _bounceController.forward(from: 0);
    final direction = math.Random().nextBool() ? 1 : -1;
    _rotationController.value += direction * 0.02;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    _rotationController.value -= direction * 0.02;
  }

  void _handleTickBoundary() {
    if (!_isSpinning || widget.slices.length < 2) {
      return;
    }

    final boundary = WheelMath.boundaryIndex(
      sliceCount: widget.slices.length,
      rotation: _rotationController.value,
    );
    if (_lastBoundary == boundary) {
      return;
    }
    _lastBoundary = boundary;

    if (widget.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    if (widget.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    if (_isSpinning) {
      return;
    }
    _lastWheelSize = size;
    _lastPointerPosition = details.localPosition;
    _lastPointerAngle = _angleForPosition(details.localPosition, size);
    _lastPointerTime = details.sourceTimeStamp;
    _gestureVelocity = 0;
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (_isSpinning) {
      return;
    }

    final currentAngle = _angleForPosition(details.localPosition, size);
    final delta = _shortestAngleDelta(_lastPointerAngle, currentAngle);
    _rotationController.value += delta;
    _lastWheelSize = size;
    _lastPointerPosition = details.localPosition;

    final now = details.sourceTimeStamp;
    final previous = _lastPointerTime;
    if (now != null && previous != null) {
      final dt =
          (now - previous).inMicroseconds / Duration.microsecondsPerSecond;
      if (dt > 0) {
        final sampledVelocity = delta / dt;
        _gestureVelocity = (_gestureVelocity * 0.55) + (sampledVelocity * 0.45);
      }
    }

    _lastPointerAngle = currentAngle;
    _lastPointerTime = now;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSpinning || widget.slices.length < 2) {
      return;
    }

    final flingVelocity = _estimateFlingAngularVelocity(details);
    final launchVelocity = (flingVelocity.abs() > _gestureVelocity.abs()
            ? flingVelocity
            : _gestureVelocity)
        .clamp(
          -(14.0 + (32.0 * _speedT)),
          14.0 + (32.0 * _speedT),
        );
    final tunedVelocity = launchVelocity * 1.35 * _gestureSpeedMultiplier;

    _lastPointerPosition = null;
    _lastPointerTime = null;
    if (tunedVelocity.abs() < (1.25 - (0.8 * _speedT))) {
      return;
    }
    spin(velocity: tunedVelocity);
  }

  double _estimateFlingAngularVelocity(DragEndDetails details) {
    final point = _lastPointerPosition;
    if (point == null || _lastWheelSize == Size.zero) {
      return 0;
    }

    final center = Offset(_lastWheelSize.width / 2, _lastWheelSize.height / 2);
    final radial = point - center;
    final radialLength = radial.distance;
    if (radialLength < 8) {
      return 0;
    }

    // Screen coordinates increase downward, so this tangent matches our
    // clockwise-positive rotation sign from _angleForPosition.
    final tangent = Offset(-radial.dy / radialLength, radial.dx / radialLength);
    final velocity = details.velocity.pixelsPerSecond;
    final tangentialSpeed = (velocity.dx * tangent.dx) + (velocity.dy * tangent.dy);
    final maxRadius = _lastWheelSize.shortestSide * 0.5;
    final effectiveRadius = radialLength.clamp(40.0, maxRadius).toDouble();
    return tangentialSpeed / effectiveRadius;
  }

  double _angleForPosition(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return math.atan2(point.dy - center.dy, point.dx - center.dx);
  }

  double _shortestAngleDelta(double from, double to) {
    var delta = to - from;
    while (delta > math.pi) {
      delta -= WheelMath.fullTurn;
    }
    while (delta < -math.pi) {
      delta += WheelMath.fullTurn;
    }
    return delta;
  }

  @override
  void didUpdateWidget(covariant SpinningWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slices.length != oldWidget.slices.length) {
      _lastBoundary = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final wheelSize = math.max(200.0, side);

        return GestureDetector(
          onPanStart: (details) =>
              _handlePanStart(details, Size(wheelSize, wheelSize)),
          onPanUpdate: (details) =>
              _handlePanUpdate(details, Size(wheelSize, wheelSize)),
          onPanEnd: _handlePanEnd,
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _idleController,
              ]),
              builder: (context, child) {
                final idleScale = _isSpinning
                    ? 1.0
                    : 1 +
                          (math.sin(_idleController.value * math.pi * 2) *
                              0.014);
                final idleGlow = _isSpinning
                    ? 0.2
                    : (0.14 +
                          (math.sin(_idleController.value * math.pi * 2) *
                              0.07));

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: wheelSize,
                      height: wheelSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: idleGlow),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: idleScale,
                      child: Transform.rotate(
                        angle: _rotationController.value,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size.square(wheelSize),
                            painter: WheelPainter(slices: widget.slices),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: wheelSize * 0.01,
                      child: _PointerIndicator(size: wheelSize),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PointerIndicator extends StatelessWidget {
  const _PointerIndicator({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: size * 0.16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: 26,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
