import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

/// Paleta para modo oscuro (complementa a [TammysColors], que es la clara).
class TammysDarkColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color border = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color divider = Color(0xFF2C2C2C);
}

/// Definiciones de tema claro y oscuro de la app.
class AppTheme {
  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: TammysColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: TammysColors.primary,
      onPrimary: Colors.white,
      surface: TammysColors.background,
      onSurface: TammysColors.textPrimary,
    );
    return _build(
      base,
      scaffold: TammysColors.background,
      appBar: TammysColors.background,
      appBarText: TammysColors.textPrimary,
    );
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: TammysColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      // En oscuro el "primario" se invierte a blanco para que los botones
      // negros sigan siendo visibles sobre fondo oscuro.
      primary: TammysDarkColors.textPrimary,
      onPrimary: Colors.black,
      surface: TammysDarkColors.surface,
      onSurface: TammysDarkColors.textPrimary,
    );
    return _build(
      base,
      scaffold: TammysDarkColors.background,
      appBar: TammysDarkColors.background,
      appBarText: TammysDarkColors.textPrimary,
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required Color scaffold,
    required Color appBar,
    required Color appBarText,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'OpenSans',
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: appBar,
        foregroundColor: appBarText,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: appBarText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'OpenSans',
        ),
        iconTheme: IconThemeData(color: appBarText),
      ),
    );
  }
}

/// Accesos rápidos a colores adaptativos según el brillo del tema actual.
/// Usar `context.tSurface`, `context.tTextPrimary`, etc. en las pantallas.
extension TammysThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get tScaffold =>
      isDark ? TammysDarkColors.background : TammysColors.background;
  Color get tSurface => isDark ? TammysDarkColors.surface : Colors.white;
  Color get tCard =>
      isDark ? TammysDarkColors.surface : TammysColors.lightGrey;
  Color get tTextPrimary =>
      isDark ? TammysDarkColors.textPrimary : TammysColors.textPrimary;
  Color get tTextSecondary =>
      isDark ? TammysDarkColors.textSecondary : TammysColors.textSecondary;
  Color get tDivider =>
      isDark ? TammysDarkColors.divider : TammysColors.divider;
  Color get tBorder =>
      isDark ? TammysDarkColors.border : TammysColors.borderColor;

  /// Color de marca para botones/acentos (se invierte en oscuro).
  Color get tBrand =>
      isDark ? TammysDarkColors.textPrimary : TammysColors.primary;
  Color get tOnBrand => isDark ? Colors.black : Colors.white;
}
