import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppTheme {
  // Cores candidatas para texto/ícone
  static const Color _darkText =
      Color(0xFF263238); // azul-acinzentado bem escuro (melhor que preto puro)
  static const Color _lightText = Colors.white;

  /// Contraste WCAG entre duas cores (quanto maior, melhor)
  static double _contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final hi = math.max(l1, l2);
    final lo = math.min(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Escolhe a melhor cor de texto/ícone para a `seed` com base no MAIOR contraste.
  static Color onForSeed(Color seed) {
    final cDark = _contrastRatio(_darkText, seed);
    final cLight = _contrastRatio(_lightText, seed);
    return (cDark >= cLight) ? _darkText : _lightText;
  }

  static Color _darken(Color c, [double amt = .10]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData lightWithSeed(Color seed) {
    final on = onForSeed(seed);

    // Esquema baseado na seed, com "on*" coerentes
    final scheme = ColorScheme.fromSeed(seedColor: seed).copyWith(
      onPrimary: on,
      onSecondary: on,
      onSurface: on,
      onBackground: on,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: seed,
      fontFamily: 'Lato',
    );

    return base.copyWith(
      // AppBar com contraste dinâmico
      appBarTheme: AppBarTheme(
        backgroundColor: seed,
        foregroundColor: on,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: on,
        ),
      ),

      // Ícones (actions, etc.)
      iconTheme: IconThemeData(color: on),

      // Tipografia base
      textTheme: base.textTheme.copyWith(
        headlineMedium: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: on,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          color: on,
        ),
        // Dígitos grandes (cartões brancos)
        displayMedium: TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w700,
          fontSize: 72,
          color: _darken(seed, .12),
        ),
      ),

      // Chips: fundo translúcido quando não selecionado; branco quando selecionado.
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: on.withOpacity(.12),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: on,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: TextStyle(
          color: on.withOpacity(.7),
          fontFamily: 'Lato',
        ),
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darken(seed, .08),
          foregroundColor: on,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  /// Compat: se alguém ainda usa `AppTheme.light`
  static ThemeData get light => lightWithSeed(const Color(0xFFF45B5E));
}
