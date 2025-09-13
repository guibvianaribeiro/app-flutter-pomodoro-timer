import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

final seedColorProvider =
    StateNotifierProvider<SeedColorNotifier, Color>((ref) {
  return SeedColorNotifier();
});

class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier() : super(const Color(0xFFF45B5E));

  void set(Color c) => state = c;
}

final themeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(seedColorProvider);
  return AppTheme.fromSeed(seed);
});
