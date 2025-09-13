import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'package:pomodoro_timer/core/services/prefs_service.dart';

final seedColorProvider =
    StateNotifierProvider<SeedColorNotifier, Color>((ref) {
  return SeedColorNotifier();
});

class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier() : super(const Color(0xFFF45B5E)) {
    _load();
  }

  Future<void> _load() async {
    final saved = await PrefsService.getSeed();
    if (saved != null) state = saved;
  }

  Future<void> set(Color c) async {
    state = c;
    await PrefsService.setSeed(c);
  }
}

final themeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(seedColorProvider);
  return AppTheme.fromSeed(seed);
});

final keepScreenOnProvider =
    StateNotifierProvider<KeepScreenOnNotifier, bool>((ref) {
  return KeepScreenOnNotifier();
});

class KeepScreenOnNotifier extends StateNotifier<bool> {
  KeepScreenOnNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await PrefsService.getKeepScreenOn();
  }

  Future<void> set(bool v) async {
    state = v;
    await PrefsService.setKeepScreenOn(v);
  }
}
