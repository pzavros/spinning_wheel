import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_settings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/animated_background.dart';
import '../../../shared/widgets/app_modal_shell.dart';
import '../../../shared/widgets/glass_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _speedLabel(int level) {
    if (level <= 3) {
      return 'Controlled';
    }
    if (level <= 7) {
      return 'Balanced';
    }
    return 'Very Fast';
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AppModalShell(
          title: 'Reset App Data',
          message:
              'Clear all wheels, slices, and settings? This cannot be undone.',
          leading: AppModalBadge(
            icon: Icons.warning_amber_rounded,
            tintedColor: scheme.error,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(appControllerProvider.notifier).resetApp();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(appControllerProvider);

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (state) {
        final settings = state.settings;
        return AnimatedFancyBackground(
          intensity: settings.backgroundIntensity,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ListView(
                  children: [
                    GlassPanel(
                      borderRadius: 30,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.16),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Adjust feedback, visuals, and app behavior.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsSection(
                      icon: Icons.graphic_eq_rounded,
                      title: 'Spin Feedback',
                      subtitle: 'Tune wheel response and winner behavior.',
                      child: Column(
                        children: [
                          _SettingsSwitchTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound',
                            subtitle: 'Play a short alert when the spin ends.',
                            value: settings.soundEnabled,
                            onChanged: (value) => ref
                                .read(appControllerProvider.notifier)
                                .toggleSound(value),
                          ),
                          const Divider(height: 1),
                          _SettingsSwitchTile(
                            icon: Icons.vibration_rounded,
                            title: 'Haptics',
                            subtitle: 'Use tactile feedback for spin results.',
                            value: settings.hapticsEnabled,
                            onChanged: (value) => ref
                                .read(appControllerProvider.notifier)
                                .toggleHaptics(value),
                          ),
                          const Divider(height: 1),
                          _SettingsSwitchTile(
                            icon: Icons.person_remove_alt_1_rounded,
                            title: 'Hide Winner Automatically',
                            subtitle:
                                'Hide the selected slice after each spin.',
                            value: settings.removeWinner,
                            onChanged: (value) => ref
                                .read(appControllerProvider.notifier)
                                .toggleRemoveWinner(value),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wheel Speed',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Control how quickly the wheel slows down.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Level ${settings.wheelSpeedLevel}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _speedLabel(settings.wheelSpeedLevel),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Slider(
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  value: settings.wheelSpeedLevel.toDouble(),
                                  label: '${settings.wheelSpeedLevel}',
                                  onChanged: (value) {
                                    final level = value.round();
                                    if (level == settings.wheelSpeedLevel) {
                                      return;
                                    }
                                    ref
                                        .read(appControllerProvider.notifier)
                                        .setWheelSpeedLevel(level);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsSection(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Customize intensity and theme style.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Background Intensity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SegmentedButton<BackgroundIntensity>(
                              segments: const [
                                ButtonSegment(
                                  value: BackgroundIntensity.low,
                                  icon: Icon(Icons.blur_off_rounded),
                                  label: Text('Low'),
                                ),
                                ButtonSegment(
                                  value: BackgroundIntensity.medium,
                                  icon: Icon(Icons.blur_on_rounded),
                                  label: Text('Med'),
                                ),
                                ButtonSegment(
                                  value: BackgroundIntensity.high,
                                  icon: Icon(Icons.auto_awesome_rounded),
                                  label: Text('High'),
                                ),
                              ],
                              selected: {settings.backgroundIntensity},
                              showSelectedIcon: false,
                              onSelectionChanged: (selection) {
                                ref
                                    .read(appControllerProvider.notifier)
                                    .setBackgroundIntensity(selection.first);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Theme',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SegmentedButton<AppThemePreference>(
                              segments: const [
                                ButtonSegment(
                                  value: AppThemePreference.system,
                                  icon: Icon(Icons.settings_suggest_rounded),
                                  label: Text('System'),
                                ),
                                ButtonSegment(
                                  value: AppThemePreference.light,
                                  icon: Icon(Icons.light_mode_rounded),
                                  label: Text('Light'),
                                ),
                                ButtonSegment(
                                  value: AppThemePreference.dark,
                                  icon: Icon(Icons.dark_mode_rounded),
                                  label: Text('Dark'),
                                ),
                              ],
                              selected: {settings.themePreference},
                              showSelectedIcon: false,
                              onSelectionChanged: (selection) {
                                ref
                                    .read(appControllerProvider.notifier)
                                    .setThemePreference(selection.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      borderRadius: 28,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Danger Zone',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'This removes every wheel and setting from the app.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            onPressed: () => _confirmReset(context, ref),
                            icon: const Icon(Icons.delete_sweep_rounded),
                            label: const Text('Reset app'),
                          ),
                        ],
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
