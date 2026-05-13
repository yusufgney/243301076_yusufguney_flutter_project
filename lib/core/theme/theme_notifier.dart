import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefKey = 'isDarkMode';

/// Tema modunu yöneten Notifier.
/// Başlangıçta SharedPreferences'dan değeri okur, varsayılan olarak light mode döner.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Senkron okuma yapmak için main.dart'ta provider'ı override edeceğiz.
    return ThemeMode.light;
  }

  /// Uygulama ilk açıldığında SharedPreferences'dan durumu yükler.
  void initialize(SharedPreferences prefs) {
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Light/Dark mode arası geçiş yapar ve kaydeder.
  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    
    state = newMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, newMode == ThemeMode.dark);
  }
}

/// Tüm uygulama üzerinden temayı dinlemek ve değiştirmek için provider.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

/// ProviderScope override'ında kullanmak için senkron SharedPreferences instance'ı
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('main.dart içinde override edilmeli');
});
