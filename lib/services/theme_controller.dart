import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el modo de tema (claro/oscuro) y lo persiste entre sesiones.
class ThemeController {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  static const String _prefKey = 'theme_mode';

  /// Notifica a la app cuando cambia el tema.
  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDark => mode.value == ThemeMode.dark;

  /// Carga la preferencia guardada. Llamar antes de runApp.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      mode.value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      mode.value = ThemeMode.light;
    }
  }

  /// Cambia el tema y lo guarda.
  Future<void> setDark(bool isDark) async {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, isDark ? 'dark' : 'light');
    } catch (_) {
      // Si falla el guardado, el cambio en memoria sigue aplicando.
    }
  }
}
