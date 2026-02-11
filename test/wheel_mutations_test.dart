import 'package:flutter_test/flutter_test.dart';
import 'package:spinning_wheel/core/models/wheel_model.dart';
import 'package:spinning_wheel/core/models/wheel_slice.dart';
import 'package:spinning_wheel/core/utils/wheel_mutations.dart';

void main() {
  WheelModel buildWheel() {
    return WheelModel(
      id: 'wheel',
      name: 'Test',
      lastUsed: DateTime(2026, 1, 1),
      slices: const [
        WheelSlice(id: 'a', label: 'A', colorValue: 1),
        WheelSlice(id: 'b', label: 'B', colorValue: 2),
        WheelSlice(id: 'c', label: 'C', colorValue: 3),
      ],
    );
  }

  group('WheelMutations', () {
    test('sanitize trims and normalizes spaces', () {
      expect(WheelMutations.sanitizeLabel('  hello    world  '), 'hello world');
    });

    test('add slice appends new item', () {
      final wheel = buildWheel();
      final updated = WheelMutations.addSlice(
        wheel,
        const WheelSlice(id: 'd', label: 'D', colorValue: 4),
      );
      expect(updated.slices.length, 4);
      expect(updated.slices.last.label, 'D');
    });

    test('reorder moves item to target position', () {
      final wheel = buildWheel();
      final updated = WheelMutations.reorderSlices(wheel, 0, 3);
      expect(updated.slices.map((slice) => slice.id), ['b', 'c', 'a']);
    });

    test('removeWinner removes selected slice', () {
      final wheel = buildWheel();
      final updated = WheelMutations.removeWinner(wheel, 'b');
      expect(updated.slices.map((slice) => slice.id), ['a', 'c']);
    });
  });
}
