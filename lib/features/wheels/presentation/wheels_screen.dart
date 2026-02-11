import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/wheel_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/animated_background.dart';
import '../../../shared/widgets/app_modal_shell.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../editor/presentation/slice_editor_sheet.dart';

class WheelsScreen extends ConsumerWidget {
  const WheelsScreen({super.key, required this.onOpenWheel});

  final VoidCallback onOpenWheel;

  Future<void> _openSliceEditorForWheel(
    BuildContext context,
    WidgetRef ref,
    WheelModel wheel,
  ) async {
    await ref.read(appControllerProvider.notifier).selectWheel(wheel.id);
    if (!context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SliceEditorSheet(wheel: wheel),
    );
  }

  Future<void> _createWheel(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _WheelNameDialog(
        title: 'Create Wheel',
        message: 'Create a new wheel with a custom name.',
        leading: AppModalBadge(icon: Icons.add_circle_outline_rounded),
        submitLabel: 'Create',
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref
          .read(appControllerProvider.notifier)
          .createWheel(name: name.trim());
    }
  }

  Future<void> _renameWheel(
    BuildContext context,
    WidgetRef ref,
    String wheelId,
    String currentName,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _WheelNameDialog(
        title: 'Rename Wheel',
        message: 'Update how this wheel appears in your list.',
        leading: const AppModalBadge(icon: Icons.drive_file_rename_outline),
        submitLabel: 'Save',
        initialValue: currentName,
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref
          .read(appControllerProvider.notifier)
          .renameWheel(wheelId, name.trim());
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String wheelId,
    String wheelName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final error = Theme.of(dialogContext).colorScheme.error;
        return AppModalShell(
          title: 'Delete Wheel',
          message:
              'Delete "$wheelName"? This keeps your other wheels unchanged.',
          leading: AppModalBadge(
            icon: Icons.delete_forever_rounded,
            tintedColor: error,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(appControllerProvider.notifier).deleteWheel(wheelId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(appControllerProvider);

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (state) {
        final wheels = [...state.wheels]
          ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));

        return AnimatedFancyBackground(
          intensity: state.settings.backgroundIntensity,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    GlassPanel(
                      child: Row(
                        children: [
                          Text(
                            'Saved Wheels',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => _createWheel(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('New'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: wheels.length,
                        itemBuilder: (context, index) {
                          final wheel = wheels[index];
                          final isCurrent = wheel.id == state.currentWheelId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassPanel(
                              padding: const EdgeInsets.all(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () async {
                                  await ref
                                      .read(appControllerProvider.notifier)
                                      .selectWheel(wheel.id);
                                  onOpenWheel();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            wheel.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                        if (isCurrent)
                                          const Chip(label: Text('Current')),
                                        PopupMenuButton<String>(
                                          onSelected: (action) async {
                                            switch (action) {
                                              case 'slices':
                                                await _openSliceEditorForWheel(
                                                  context,
                                                  ref,
                                                  wheel,
                                                );
                                              case 'rename':
                                                await _renameWheel(
                                                  context,
                                                  ref,
                                                  wheel.id,
                                                  wheel.name,
                                                );
                                              case 'duplicate':
                                                await ref
                                                    .read(
                                                      appControllerProvider
                                                          .notifier,
                                                    )
                                                    .duplicateWheel(wheel.id);
                                              case 'delete':
                                                await _confirmDelete(
                                                  context,
                                                  ref,
                                                  wheel.id,
                                                  wheel.name,
                                                );
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'slices',
                                              child: Text(
                                                'Manage Slices (Add/Edit/Remove)',
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'rename',
                                              child: Text('Rename'),
                                            ),
                                            PopupMenuItem(
                                              value: 'duplicate',
                                              child: Text('Duplicate'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: wheel.slices.take(6).map((
                                        slice,
                                      ) {
                                        return Chip(
                                          label: Text(slice.label),
                                          backgroundColor: Color(
                                            slice.colorValue,
                                          ).withValues(alpha: 0.2),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${wheel.slices.where((slice) => !slice.isHidden).length} active / ${wheel.slices.length} total  |  Last used ${DateFormat('MMM d, HH:mm').format(wheel.lastUsed)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () => _openSliceEditorForWheel(
                                            context,
                                            ref,
                                            wheel,
                                          ),
                                          icon: const Icon(
                                            Icons.edit_note_rounded,
                                          ),
                                          label: const Text('Slices'),
                                        ),
                                      ],
                                    ),
                                  ],
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
  }
}

class _WheelNameDialog extends StatefulWidget {
  const _WheelNameDialog({
    required this.title,
    required this.message,
    required this.leading,
    required this.submitLabel,
    this.initialValue = '',
  });

  final String title;
  final String message;
  final Widget leading;
  final String submitLabel;
  final String initialValue;

  @override
  State<_WheelNameDialog> createState() => _WheelNameDialogState();
}

class _WheelNameDialogState extends State<_WheelNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AppModalShell(
      title: widget.title,
      message: widget.message,
      leading: widget.leading,
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Wheel name',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
