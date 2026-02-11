import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/root/root_shell.dart';

class SpinMasterApp extends ConsumerWidget {
  const SpinMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      appControllerProvider.select(
        (state) => state.valueOrNull?.settings.themeMode ?? ThemeMode.system,
      ),
    );

    return MaterialApp(
      title: 'Spin Master',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const RootShell(),
    );
  }
}
