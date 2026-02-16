import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/app_state.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/animated_background.dart';
import '../../../shared/widgets/app_modal_shell.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/pressable_button.dart';
import '../../editor/presentation/slice_editor_sheet.dart';
import '../../presets/data/preset_library.dart';
import 'widgets/result_dialog.dart';
import 'widgets/spinning_wheel.dart';

class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen> {
  final GlobalKey<SpinningWheelState> _wheelKey =
      GlobalKey<SpinningWheelState>();
  bool _isSpinning = false;

  Future<void> _shareWinnerResult(String winner) async {
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;

    try {
      final result = await Share.share(
        'Spin Master picked: $winner',
        sharePositionOrigin: origin,
      );
      if (!mounted || result.status != ShareResultStatus.unavailable) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is not available right now.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the share sheet.')),
      );
    }
  }

  Future<void> _openWheelChooser(AppState appState) async {
    final sortedWheels = [...appState.wheels]
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

    final selectedWheelId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GlassPanel(
              borderRadius: 30,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.62,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: scheme.onSurface.withValues(alpha: 0.24),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.toll_rounded, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Choose Wheel',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Text(
                          '${sortedWheels.length} total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pick a wheel to load into the spinner.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sortedWheels.length,
                        itemBuilder: (context, index) {
                          final savedWheel = sortedWheels[index];
                          final isCurrent =
                              savedWheel.id == appState.currentWheelId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () =>
                                    Navigator.of(context).pop(savedWheel.id),
                                child: Ink(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: isCurrent
                                        ? scheme.primary.withValues(alpha: 0.15)
                                        : scheme.surface.withValues(alpha: 0.24),
                                    border: Border.all(
                                      color: isCurrent
                                          ? scheme.primary.withValues(alpha: 0.5)
                                          : scheme.outline.withValues(
                                              alpha: 0.2,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (isCurrent
                                                  ? scheme.primary
                                                  : scheme.onSurface)
                                              .withValues(alpha: 0.14),
                                        ),
                                        child: Icon(
                                          isCurrent
                                              ? Icons.check_rounded
                                              : Icons.casino_rounded,
                                          size: 18,
                                          color: isCurrent
                                              ? scheme.primary
                                              : scheme.onSurface.withValues(
                                                  alpha: 0.85,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              savedWheel.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${savedWheel.slices.where((slice) => !slice.isHidden).length} active / ${savedWheel.slices.length} total',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCurrent)
                                        Chip(
                                          label: const Text('Current'),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(
                                            color: scheme.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                          ),
                                          backgroundColor: scheme.primary
                                              .withValues(alpha: 0.14),
                                        )
                                      else
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted ||
        selectedWheelId == null ||
        selectedWheelId == appState.currentWheelId) {
      return;
    }

    await ref.read(appControllerProvider.notifier).selectWheel(selectedWheelId);
  }

  Future<void> _spin() async {
    await ref.read(appControllerProvider.notifier).touchCurrentWheel();
    await _wheelKey.currentState?.spin();
  }

  Future<void> _openSliceEditor() async {
    final state = ref.read(appControllerProvider).valueOrNull;
    final wheel = state?.currentWheel;
    if (wheel == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SliceEditorSheet(wheel: wheel),
    );
  }

  Future<void> _openPresets() async {
    final presets = PresetLibrary.all();
    final selected = await showModalBottomSheet<Preset>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassPanel(
              borderRadius: 28,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Preset Wheels',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick load curated wheel ideas.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: presets.length,
                        itemBuilder: (context, index) {
                          final preset = presets[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.22),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.12),
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.auto_awesome),
                              title: Text(preset.name),
                              subtitle: Text('${preset.items.length} slices'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => Navigator.of(context).pop(preset),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    final mode = await showDialog<String>(
      context: context,
      builder: (context) {
        return AppModalShell(
          title: selected.name,
          message: 'How do you want to use this preset?',
          leading: const AppModalBadge(icon: Icons.auto_awesome_rounded),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Save as New Wheel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'load'),
              child: const Text('Load Into Current'),
            ),
          ],
        );
      },
    );

    if (mode == 'load') {
      await ref
          .read(appControllerProvider.notifier)
          .loadPresetIntoCurrent(selected);
    }
    if (mode == 'save') {
      final wheelCountBeforeCreate =
          ref.read(appControllerProvider).valueOrNull?.wheels.length ?? 0;
      await ref
          .read(appControllerProvider.notifier)
          .savePresetAsWheel(selected);
      final wheelCountAfterCreate =
          ref.read(appControllerProvider).valueOrNull?.wheels.length ??
          wheelCountBeforeCreate;
      await ref
          .read(adMonetizationServiceProvider)
          .registerWheelCreated(
            wheelCountBeforeCreate: wheelCountBeforeCreate,
            wheelCountAfterCreate: wheelCountAfterCreate,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved "${selected.name}" as a wheel.')),
        );
      }
    }
  }

  Future<void> _onSpinResult(int index) async {
    final appState = ref.read(appControllerProvider).valueOrNull;
    final wheel = appState?.currentWheel;
    final settings = appState?.settings;
    final activeSlices = wheel?.slices
        .where((slice) => !slice.isHidden)
        .toList(growable: false);
    if (wheel == null ||
        settings == null ||
        index < 0 ||
        activeSlices == null ||
        index >= activeSlices.length) {
      return;
    }

    final winner = activeSlices[index];

    if (settings.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }

    await ref.read(adMonetizationServiceProvider).registerCompletedSpin();
    if (!mounted) {
      return;
    }

    final action = await showResultDialog(
      context,
      winner: winner.label,
      canRemoveWinner: activeSlices.length > 1,
    );

    if (!mounted) {
      return;
    }

    if (action == ResultDialogAction.share) {
      await _shareWinnerResult(winner.label);
    }

    final shouldRemove =
        settings.removeWinner || action == ResultDialogAction.removeWinner;
    if (shouldRemove) {
      await ref
          .read(appControllerProvider.notifier)
          .removeWinnerFromCurrentWheel(winner.id);
    }

    if (action == ResultDialogAction.spinAgain) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) {
        await _spin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateAsync = ref.watch(appControllerProvider);

    return appStateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (appState) {
        final wheel = appState.currentWheel;
        final settings = appState.settings;

        if (wheel == null) {
          return const Center(child: Text('Create a wheel to get started.'));
        }

        final activeSlices = wheel.slices
            .where((slice) => !slice.isHidden)
            .toList(growable: false);
        final canSpin = activeSlices.length > 1;

        return AnimatedFancyBackground(
          intensity: settings.backgroundIntensity,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    GlassPanel(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.toll_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Wheel',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              _ControlIconButton(
                                onPressed: _openPresets,
                                tooltip: 'Presets',
                                icon: Icons.auto_awesome_rounded,
                              ),
                              const SizedBox(width: 6),
                              _ControlIconButton(
                                onPressed: _openSliceEditor,
                                tooltip: 'Edit slices',
                                icon: Icons.edit_note_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _WheelChooserField(
                            wheelName: wheel.name,
                            sliceCount: activeSlices.length,
                            totalSliceCount: wheel.slices.length,
                            onTap: () => _openWheelChooser(appState),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SpinningWheel(
                            key: _wheelKey,
                            slices: activeSlices,
                            soundEnabled: settings.soundEnabled,
                            hapticsEnabled: settings.hapticsEnabled,
                            speedLevel: settings.wheelSpeedLevel,
                            onResult: _onSpinResult,
                            onSpinStateChanged: (spinning) {
                              if (_isSpinning != spinning) {
                                setState(() => _isSpinning = spinning);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!canSpin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Keep at least 2 visible slices to spin the wheel.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Center(
                      child: PressableButton(
                        label: 'SPIN',
                        icon: Icons.casino_rounded,
                        enabled: canSpin && !_isSpinning,
                        onPressed: _spin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon),
      ),
    );
  }
}

class _WheelChooserField extends StatelessWidget {
  const _WheelChooserField({
    required this.wheelName,
    required this.sliceCount,
    required this.totalSliceCount,
    required this.onTap,
  });

  final String wheelName;
  final int sliceCount;
  final int totalSliceCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: scheme.surface.withValues(alpha: 0.26),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.casino_outlined,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wheelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sliceCount active / $totalSliceCount total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
