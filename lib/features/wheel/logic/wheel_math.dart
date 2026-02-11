import 'dart:math' as math;

class WheelMath {
  static const double fullTurn = math.pi * 2;
  static const double pointerAngle = -math.pi / 2;

  static double normalize(double angle) {
    final mod = angle % fullTurn;
    if (mod < 0) {
      return mod + fullTurn;
    }
    return mod;
  }

  static double sweepAngle(int sliceCount) {
    if (sliceCount <= 0) {
      return fullTurn;
    }
    return fullTurn / sliceCount;
  }

  static double wheelStartAngle(int sliceCount) {
    final sweep = sweepAngle(sliceCount);
    return pointerAngle - (sweep / 2);
  }

  static int winnerIndex({required int sliceCount, required double rotation}) {
    if (sliceCount <= 0) {
      return -1;
    }

    final sweep = sweepAngle(sliceCount);
    final start = wheelStartAngle(sliceCount);
    final localPointer = normalize(pointerAngle - rotation - start);
    return (localPointer / sweep).floor() % sliceCount;
  }

  static int boundaryIndex({
    required int sliceCount,
    required double rotation,
  }) {
    if (sliceCount <= 0) {
      return -1;
    }
    return winnerIndex(sliceCount: sliceCount, rotation: rotation);
  }
}
