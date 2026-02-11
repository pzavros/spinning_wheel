import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/presets/data/preset_library.dart';
import '../models/app_settings.dart';
import '../models/app_state.dart';
import '../models/wheel_model.dart';
import '../models/wheel_slice.dart';
import '../providers/app_providers.dart';
import '../utils/color_palette.dart';
import '../utils/wheel_mutations.dart';

class AppController extends AsyncNotifier<AppState> {
  final Uuid _uuid = const Uuid();

  @override
  Future<AppState> build() async {
    final storage = ref.read(appStorageProvider);
    final loaded = await storage.loadState();
    if (loaded != null && loaded.wheels.isNotEmpty) {
      return loaded;
    }
    final fallback = _defaultState();
    await storage.saveState(fallback);
    return fallback;
  }

  AppState _defaultState() {
    final starter = _buildWheel(
      name: 'Decision Wheel',
      labels: ['Yes', 'No', 'Maybe', 'Ask Again'],
    );
    return AppState.initial(starterWheel: starter);
  }

  WheelModel _buildWheel({required String name, required List<String> labels}) {
    final slices = List<WheelSlice>.generate(labels.length, (index) {
      return WheelSlice(
        id: _uuid.v4(),
        label: labels[index],
        colorValue: SliceColorPalette.colorForIndex(index),
      );
    });
    return WheelModel(
      id: _uuid.v4(),
      name: name,
      slices: slices,
      lastUsed: DateTime.now(),
    );
  }

  Future<void> _persist(AppState next) async {
    final storage = ref.read(appStorageProvider);
    await storage.saveState(next);
  }

  Future<void> _apply(AppState next) async {
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> selectWheel(String wheelId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(current.copyWith(currentWheelId: wheelId));
  }

  Future<void> touchCurrentWheel() async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }
    final updatedWheel = wheel.copyWith(lastUsed: DateTime.now());
    final next = current.copyWith(
      wheels: current.wheels
          .map((item) => item.id == wheel.id ? updatedWheel : item)
          .toList(),
    );
    await _apply(next);
  }

  Future<void> addSlice(String rawLabel) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }

    if (!WheelMutations.isValidLabel(rawLabel)) {
      return;
    }

    final slice = WheelSlice(
      id: _uuid.v4(),
      label: WheelMutations.sanitizeLabel(rawLabel),
      colorValue: SliceColorPalette.colorForIndex(wheel.slices.length),
    );
    final updatedWheel = WheelMutations.addSlice(wheel, slice);
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> editSlice(String sliceId, String nextLabel) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }
    if (!WheelMutations.isValidLabel(nextLabel)) {
      return;
    }

    final updatedWheel = WheelMutations.updateSliceLabel(
      wheel,
      sliceId,
      nextLabel,
    );
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> deleteSlice(String sliceId) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }
    final updatedWheel = WheelMutations.deleteSlice(wheel, sliceId);
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> reorderSlices(int oldIndex, int newIndex) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }
    final updatedWheel = WheelMutations.reorderSlices(
      wheel,
      oldIndex,
      newIndex,
    );
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> randomizeSliceColors() async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }

    final colors = SliceColorPalette.shuffledColorValues(wheel.slices.length);
    final updatedWheel = wheel.copyWith(
      slices: List<WheelSlice>.generate(wheel.slices.length, (index) {
        return wheel.slices[index].copyWith(colorValue: colors[index]);
      }),
    );
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> loadPresetIntoCurrent(Preset preset) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }

    final slices = List<WheelSlice>.generate(preset.items.length, (index) {
      return WheelSlice(
        id: _uuid.v4(),
        label: WheelMutations.sanitizeLabel(preset.items[index]),
        colorValue: SliceColorPalette.colorForIndex(index),
      );
    });

    final updatedWheel = wheel.copyWith(
      slices: slices,
      lastUsed: DateTime.now(),
    );
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<void> savePresetAsWheel(Preset preset) async {
    await createWheel(
      name: preset.name,
      labels: preset.items,
      autoSelect: false,
    );
  }

  Future<void> createWheel({
    required String name,
    List<String>? labels,
    bool autoSelect = true,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final inputLabels = labels ?? ['Option 1', 'Option 2'];
    final validLabels = inputLabels
        .map(WheelMutations.sanitizeLabel)
        .where((label) => label.isNotEmpty)
        .take(20)
        .toList();
    if (validLabels.isEmpty) {
      return;
    }

    final wheel = _buildWheel(name: trimmedName, labels: validLabels);
    final next = current.copyWith(
      wheels: [...current.wheels, wheel],
      currentWheelId: autoSelect ? wheel.id : current.currentWheelId,
    );
    await _apply(next);
  }

  Future<void> renameWheel(String wheelId, String nextName) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final cleaned = nextName.trim();
    if (cleaned.isEmpty) {
      return;
    }

    final updatedWheels = current.wheels
        .map(
          (wheel) =>
              wheel.id == wheelId ? wheel.copyWith(name: cleaned) : wheel,
        )
        .toList();
    await _apply(current.copyWith(wheels: updatedWheels));
  }

  Future<void> duplicateWheel(String wheelId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final source = current.wheels
        .where((wheel) => wheel.id == wheelId)
        .firstOrNull;
    if (source == null) {
      return;
    }

    final duplicate = source.copyWith(
      id: _uuid.v4(),
      name: '${source.name} Copy',
      slices: source.slices
          .map((slice) => slice.copyWith(id: _uuid.v4()))
          .toList(growable: false),
      lastUsed: DateTime.now(),
    );

    await _apply(current.copyWith(wheels: [...current.wheels, duplicate]));
  }

  Future<void> deleteWheel(String wheelId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final remaining = current.wheels
        .where((wheel) => wheel.id != wheelId)
        .toList();
    if (remaining.isEmpty) {
      final fallback = _defaultState();
      await _apply(fallback);
      return;
    }

    final nextCurrent = current.currentWheelId == wheelId
        ? remaining.first.id
        : current.currentWheelId;

    await _apply(
      current.copyWith(wheels: remaining, currentWheelId: nextCurrent),
    );
  }

  Future<void> removeWinnerFromCurrentWheel(String sliceId) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return;
    }

    final visibleCount = wheel.slices.where((slice) => !slice.isHidden).length;
    final target = wheel.slices.where((slice) => slice.id == sliceId).firstOrNull;
    if (target == null || target.isHidden || visibleCount <= 1) {
      return;
    }

    final updatedWheel = WheelMutations.removeWinner(wheel, sliceId);
    await _replaceCurrentWheel(current, updatedWheel);
  }

  Future<bool> setSliceHidden(String sliceId, bool hidden) async {
    final current = state.valueOrNull;
    final wheel = current?.currentWheel;
    if (current == null || wheel == null) {
      return false;
    }

    final target = wheel.slices.where((slice) => slice.id == sliceId).firstOrNull;
    if (target == null || target.isHidden == hidden) {
      return false;
    }

    if (hidden) {
      final visibleCount = wheel.slices.where((slice) => !slice.isHidden).length;
      if (visibleCount <= 1) {
        return false;
      }
    }

    final updatedWheel = wheel.copyWith(
      slices: wheel.slices
          .map(
            (slice) =>
                slice.id == sliceId ? slice.copyWith(isHidden: hidden) : slice,
          )
          .toList(),
    );
    await _replaceCurrentWheel(current, updatedWheel);
    return true;
  }

  Future<void> updateSettings(AppSettings nextSettings) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(current.copyWith(settings: nextSettings));
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(themePreference: preference),
      ),
    );
  }

  Future<void> setBackgroundIntensity(BackgroundIntensity intensity) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(backgroundIntensity: intensity),
      ),
    );
  }

  Future<void> setWheelSpeedLevel(int level) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(
          wheelSpeedLevel: level.clamp(1, 10).toInt(),
        ),
      ),
    );
  }

  Future<void> toggleSound(bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(soundEnabled: value),
      ),
    );
  }

  Future<void> toggleHaptics(bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(hapticsEnabled: value),
      ),
    );
  }

  Future<void> toggleRemoveWinner(bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _apply(
      current.copyWith(
        settings: current.settings.copyWith(removeWinner: value),
      ),
    );
  }

  Future<void> resetApp() async {
    final storage = ref.read(appStorageProvider);
    await storage.clear();
    final fallback = _defaultState();
    await _apply(fallback);
  }

  Future<void> _replaceCurrentWheel(AppState appState, WheelModel wheel) async {
    final next = appState.copyWith(
      wheels: appState.wheels
          .map((candidate) => candidate.id == wheel.id ? wheel : candidate)
          .toList(),
    );
    await _apply(next);
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
