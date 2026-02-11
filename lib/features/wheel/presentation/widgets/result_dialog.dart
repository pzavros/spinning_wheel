import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass_panel.dart';

enum ResultDialogAction { spinAgain, removeWinner, share, close }

Future<ResultDialogAction?> showResultDialog(
  BuildContext context, {
  required String winner,
  required bool canRemoveWinner,
}) {
  return showGeneralDialog<ResultDialogAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Result',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _ResultDialog(winner: winner, canRemoveWinner: canRemoveWinner);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ResultDialog extends StatefulWidget {
  const _ResultDialog({required this.winner, required this.canRemoveWinner});

  final String winner;
  final bool canRemoveWinner;

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1400),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _close(ResultDialogAction action) {
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const SizedBox.expand(),
        ),
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 42,
            maxBlastForce: 18,
            minBlastForce: 8,
            gravity: 0.18,
            shouldLoop: false,
            emissionFrequency: 0.05,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassPanel(
              borderRadius: 30,
              padding: const EdgeInsets.all(24),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.34),
                            scheme.secondary.withValues(alpha: 0.26),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: scheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Winner Confirmed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This spin landed on',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: scheme.surface.withValues(alpha: 0.24),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        widget.winner,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(fontSize: 34),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _close(ResultDialogAction.spinAgain),
                        icon: const Icon(Icons.casino_rounded),
                        label: const Text('Spin Again'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.canRemoveWinner
                            ? () => _close(ResultDialogAction.removeWinner)
                            : null,
                        icon: const Icon(Icons.person_remove_alt_1_rounded),
                        label: const Text('Hide Winner'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _close(ResultDialogAction.share),
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Share Result'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
