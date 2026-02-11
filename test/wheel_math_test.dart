import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:spinning_wheel/features/wheel/logic/wheel_math.dart';

void main() {
  group('WheelMath winnerIndex', () {
    test('returns first slice at zero rotation', () {
      final index = WheelMath.winnerIndex(sliceCount: 4, rotation: 0);
      expect(index, 0);
    });

    test('rotation by one sweep clockwise selects previous slice', () {
      final sweep = WheelMath.sweepAngle(4);
      final index = WheelMath.winnerIndex(sliceCount: 4, rotation: sweep);
      expect(index, 3);
    });

    test('rotation wraps correctly', () {
      final index = WheelMath.winnerIndex(
        sliceCount: 6,
        rotation: 13 * math.pi,
      );
      expect(index, inInclusiveRange(0, 5));
    });

    test('returns -1 for empty wheel', () {
      expect(WheelMath.winnerIndex(sliceCount: 0, rotation: 0), -1);
    });
  });
}
