import 'package:flutter/material.dart';

import '../../features/settings/presentation/settings_screen.dart';
import '../../features/wheel/presentation/wheel_screen.dart';
import '../../features/wheels/presentation/wheels_screen.dart';
import '../../shared/widgets/glass_panel.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const _navItems = <_RootNavItem>[
    _RootNavItem(label: 'Spin', icon: Icons.casino_rounded),
    _RootNavItem(label: 'Wheels', icon: Icons.toll_rounded),
    _RootNavItem(label: 'Settings', icon: Icons.tune_rounded),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const WheelScreen(),
      WheelsScreen(
        onOpenWheel: () {
          setState(() => _index = 0);
        },
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassPanel(
          borderRadius: 30,
          padding: const EdgeInsets.all(6),
          child: Row(
            children: List.generate(_navItems.length, (itemIndex) {
              final item = _navItems[itemIndex];
              final isSelected = itemIndex == _index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _RootNavButton(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => setState(() => _index = itemIndex),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _RootNavButton extends StatelessWidget {
  const _RootNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _RootNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.72),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RootNavItem {
  const _RootNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
