import 'package:flutter/material.dart';

import 'glass_panel.dart';

class AppModalShell extends StatelessWidget {
  const AppModalShell({
    super.key,
    required this.title,
    this.message,
    this.leading,
    this.content,
    this.actions = const <Widget>[],
    this.maxWidth = 460,
    this.padding = const EdgeInsets.all(22),
  });

  final String title;
  final String? message;
  final Widget? leading;
  final Widget? content;
  final List<Widget> actions;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.84;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxDialogHeight,
        ),
        child: GlassPanel(
          borderRadius: 30,
          padding: padding,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[leading!, const SizedBox(height: 14)],
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    letterSpacing: -0.2,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.82),
                      height: 1.35,
                    ),
                  ),
                ],
                if (content != null) ...[const SizedBox(height: 16), content!],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppModalBadge extends StatelessWidget {
  const AppModalBadge({super.key, required this.icon, this.tintedColor});

  final IconData icon;
  final Color? tintedColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = tintedColor ?? scheme.primary;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [tint.withValues(alpha: 0.28), tint.withValues(alpha: 0.12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: tint.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, color: tint),
    );
  }
}
