import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/wheel_model.dart';
import '../../../core/models/wheel_slice.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/wheel_mutations.dart';
import '../../../shared/widgets/app_modal_shell.dart';
import '../../../shared/widgets/glass_panel.dart';

class SliceEditorSheet extends ConsumerStatefulWidget {
  const SliceEditorSheet({super.key, required this.wheel});

  final WheelModel wheel;

  @override
  ConsumerState<SliceEditorSheet> createState() => _SliceEditorSheetState();
}

class _SliceEditorSheetState extends ConsumerState<SliceEditorSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _addController = TextEditingController();
  bool _inputExpanded = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addSlice() async {
    final label = _addController.text;
    if (!WheelMutations.isValidLabel(label)) {
      _showMessage('Slice text must be 1-30 characters.');
      return;
    }

    await ref.read(appControllerProvider.notifier).addSlice(label);
    _addController.clear();
  }

  Future<void> _editSlice(WheelSlice slice) async {
    final label = await showDialog<String>(
      context: context,
      builder: (_) => _SliceLabelDialog(initialLabel: slice.label),
    );

    if (label == null) {
      return;
    }

    if (!WheelMutations.isValidLabel(label)) {
      _showMessage('Slice text must be 1-30 characters.');
      return;
    }

    await ref.read(appControllerProvider.notifier).editSlice(slice.id, label);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider).valueOrNull;
    final wheel =
        appState?.wheels
            .where((candidate) => candidate.id == widget.wheel.id)
            .firstOrNull ??
        widget.wheel;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: GlassPanel(
          borderRadius: 28,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Slices',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ref
                          .read(appControllerProvider.notifier)
                          .randomizeSliceColors(),
                      icon: const Icon(Icons.palette_outlined),
                      tooltip: 'Randomize colors',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(
                                  () => _inputExpanded = !_inputExpanded,
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: Text(
                                _inputExpanded ? 'Close Add' : 'Add Slice',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_inputExpanded) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addController,
                          maxLength: WheelMutations.maxSliceLength,
                          decoration: InputDecoration(
                            hintText: 'Text or emoji',
                            suffixIcon: IconButton(
                              onPressed: _addSlice,
                              icon: const Icon(Icons.check_rounded),
                            ),
                          ),
                          onSubmitted: (_) => _addSlice(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: wheel.slices.isEmpty
                      ? const Center(
                          child: Text('No slices yet. Add your first one.'),
                        )
                      : ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: wheel.slices.length,
                          onReorder: (oldIndex, newIndex) {
                            ref
                                .read(appControllerProvider.notifier)
                                .reorderSlices(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final slice = wheel.slices[index];
                            return Dismissible(
                              key: ValueKey(slice.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(appControllerProvider.notifier)
                                    .deleteSlice(slice.id);
                              },
                              child: Card(
                                key: ValueKey('slice-card-${slice.id}'),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(slice.colorValue),
                                  ),
                                  title: Text(
                                    slice.label,
                                    style: slice.isHidden
                                        ? const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          )
                                        : null,
                                  ),
                                  subtitle: slice.isHidden
                                      ? const Text('Hidden from wheel')
                                      : null,
                                  onTap: () => _editSlice(slice),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: slice.isHidden
                                            ? 'Show in wheel'
                                            : 'Hide from wheel',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () async {
                                          final updated = await ref
                                              .read(
                                                appControllerProvider.notifier,
                                              )
                                              .setSliceHidden(
                                                slice.id,
                                                !slice.isHidden,
                                              );
                                          if (!updated) {
                                            _showMessage(
                                              'At least one visible slice is required.',
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          slice.isHidden
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remove slice',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          ref
                                              .read(
                                                appControllerProvider.notifier,
                                              )
                                              .deleteSlice(slice.id);
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                        ),
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(
                                          Icons.drag_handle_rounded,
                                        ),
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
  }
}

class _SliceLabelDialog extends StatefulWidget {
  const _SliceLabelDialog({required this.initialLabel});

  final String initialLabel;

  @override
  State<_SliceLabelDialog> createState() => _SliceLabelDialogState();
}

class _SliceLabelDialogState extends State<_SliceLabelDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLabel);
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
      title: 'Edit Slice',
      message: 'Update the label shown on this wheel segment.',
      leading: const AppModalBadge(icon: Icons.edit_rounded),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: WheelMutations.maxSliceLength,
        decoration: const InputDecoration(
          hintText: 'Slice text',
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
