import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_notifier.dart';

/// AppBar için yeniden kullanılabilir ikon butonu.
class ThemeToggleIconButton extends ConsumerWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
    );
  }
}

/// Ayarlar sayfası vb. yerler için yeniden kullanılabilir SwitchListTile.
class ThemeToggleListTile extends ConsumerWidget {
  const ThemeToggleListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: const Text('Tema rengini değiştir'),
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      value: isDark,
      onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
    );
  }
}
