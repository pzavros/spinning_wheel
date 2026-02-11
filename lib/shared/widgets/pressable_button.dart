import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  const PressableButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown(TapDownDetails _) {
    if (!widget.enabled) {
      return;
    }
    _controller.animateTo(1, curve: Curves.easeOutCubic);
  }

  void _pressUp([dynamic _]) {
    _controller.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: _pressDown,
      onTapCancel: _pressUp,
      onTapUp: _pressUp,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = 1 - (_controller.value * 0.06);
          return Transform.scale(scale: value, child: child);
        },
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.45,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
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
