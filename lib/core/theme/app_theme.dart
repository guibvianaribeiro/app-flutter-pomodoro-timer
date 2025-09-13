import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData fromSeed(Color seed) {
    final isSeedLight = seed.computeLuminance() > 0.5;
    final brightness = isSeedLight ? Brightness.light : Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final on = onForSeed(seed);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: seed,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: on,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: on,
        ),
        iconTheme: IconThemeData(color: on),
      ),
      iconTheme: IconThemeData(color: on),
      textTheme: Typography.blackCupertino.apply(
        displayColor: on,
        bodyColor: on,
      ),
    );
  }
  static Color onForSeed(Color seed) {
    final luminance = seed.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF263238) : Colors.white;
  }
  static Color digitsOnCard(Color seed) {
    final hsl = HSLColor.fromColor(seed);
    final newLightness = (hsl.lightness * 0.35).clamp(0.18, 0.38);
    final newSaturation = (hsl.saturation * 0.85).clamp(0.45, 0.95);
    return hsl
        .withLightness(newLightness.toDouble())
        .withSaturation(newSaturation.toDouble())
        .toColor();
  }

  static List<BoxShadow> softShadow(Color seed) => const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ];

  static Color selectedPillBg(Color seed) {
    final on = onForSeed(seed);
    return Color.alphaBlend(on.withAlpha(0x33), seed);
  }

  static Color unselectedPillBg(Color seed) {
    final on = onForSeed(seed);
    // Levemente mais contrastado para melhorar a acessibilidade
    return Color.alphaBlend(on.withAlpha(0x20), seed);
  }
}
