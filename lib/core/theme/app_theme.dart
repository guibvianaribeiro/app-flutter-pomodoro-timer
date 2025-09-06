import 'package:flutter/material.dart';

class AppTheme {
  static bool isLightSeed(Color seed) => seed.computeLuminance() > 0.62;
  static Color onForSeed(Color seed) =>
      isLightSeed(seed) ? const Color(0xFF263238) : Colors.white;

  static Color _darken(Color c, [double amt = .10]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData lightWithSeed(Color seed) {
    final on = onForSeed(seed);
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
      iconTheme: IconThemeData(color: on),
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
        // dígitos grandes (cards claros)
        displayMedium: TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w700,
          fontSize: 72,
          color: _darken(seed, .12),
        ),
      ),
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

  static ThemeData get light => lightWithSeed(const Color(0xFFF45B5E));
}
