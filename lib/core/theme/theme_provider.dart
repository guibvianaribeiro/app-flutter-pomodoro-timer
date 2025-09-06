import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/services/prefs_service.dart';

final prefsServiceProvider = Provider<PrefsService>((_) => PrefsService());

class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier(this._prefs) : super(const Color(0xFFF45B5E)) {
    _load();
  }
  final PrefsService _prefs;

  Future<void> _load() async {
    final c = await _prefs.loadSeedColor();
    if (c != null) state = c;
  }

  Future<void> set(Color c) async {
    state = c;
    await _prefs.saveSeedColor(c);
  }
}

final seedColorProvider = StateNotifierProvider<SeedColorNotifier, Color>(
  (ref) {
    final prefs = ref.read(prefsServiceProvider);
    return SeedColorNotifier(prefs);
  },
);
