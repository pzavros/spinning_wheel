import '../models/wheel_model.dart';
import '../models/wheel_slice.dart';

class WheelMutations {
  static const int maxSliceLength = 30;

  static String sanitizeLabel(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool isValidLabel(String raw) {
    final label = sanitizeLabel(raw);
    return label.isNotEmpty && label.length <= maxSliceLength;
  }

  static WheelModel addSlice(WheelModel wheel, WheelSlice slice) {
    return wheel.copyWith(slices: [...wheel.slices, slice]);
  }

  static WheelModel updateSliceLabel(
    WheelModel wheel,
    String sliceId,
    String nextLabel,
  ) {
    return wheel.copyWith(
      slices: wheel.slices
          .map(
            (slice) => slice.id == sliceId
                ? slice.copyWith(label: sanitizeLabel(nextLabel))
                : slice,
          )
          .toList(),
    );
  }

  static WheelModel deleteSlice(WheelModel wheel, String sliceId) {
    return wheel.copyWith(
      slices: wheel.slices.where((slice) => slice.id != sliceId).toList(),
    );
  }

  static WheelModel reorderSlices(
    WheelModel wheel,
    int oldIndex,
    int newIndex,
  ) {
    final updated = [...wheel.slices];
    final targetIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final item = updated.removeAt(oldIndex);
    updated.insert(targetIndex, item);
    return wheel.copyWith(slices: updated);
  }

  static WheelModel removeWinner(WheelModel wheel, String sliceId) {
    return wheel.copyWith(
      slices: wheel.slices
          .map(
            (slice) =>
                slice.id == sliceId ? slice.copyWith(isHidden: true) : slice,
          )
          .toList(),
    );
  }
}
