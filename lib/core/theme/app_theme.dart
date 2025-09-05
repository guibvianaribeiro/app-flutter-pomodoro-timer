import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        primary: AppColors.coral,
        onPrimary: AppColors.onCoral,
        surface: AppColors.coral,
        onSurface: AppColors.onCoral,
      ),
      scaffoldBackgroundColor: AppColors.coral,
      fontFamily: 'Lato', // Lato como padrão
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.coral,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.onCoral,
        titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.onCoral,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.onCoral),
        displayMedium: const TextStyle(
            // dígitos
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
            fontSize: 72,
            color: AppColors.cardText),
        bodyMedium: const TextStyle(
            fontFamily: 'Lato', fontSize: 16, color: AppColors.onCoral),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coralDark,
          foregroundColor: AppColors.onCoral,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
