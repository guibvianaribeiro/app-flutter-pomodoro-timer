import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_state.dart';

class PrefsService {
  static const _kSeedColor = 'seed_color';
  static const _kFocusMins = 'focus_mins';
  static const _kShortMins = 'short_mins';
  static const _kLongMins = 'long_mins';
  static const _kCyclesPerLong = 'cycles_per_long';
  static const _kDailyTarget = 'daily_target';
  static const _kAutoStartNext = 'auto_start_next';

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  // Seed color
  Future<void> saveSeedColor(Color c) async {
    final p = await _p;
    await p.setInt(_kSeedColor, c.value);
  }

  Future<Color?> loadSeedColor() async {
    final p = await _p;
    final v = p.getInt(_kSeedColor);
    return v == null ? null : Color(v);
  }

  // Config Pomodoro
  Future<void> saveConfig(PomodoroConfig c) async {
    final p = await _p;
    await p.setInt(_kFocusMins, c.focusMinutes);
    await p.setInt(_kShortMins, c.shortBreakMinutes);
    await p.setInt(_kLongMins, c.longBreakMinutes);
    await p.setInt(_kCyclesPerLong, c.cyclesPerLongBreak);
    await p.setInt(_kDailyTarget, c.dailyTargetCycles);
    await p.setBool(_kAutoStartNext, c.autoStartNext);
  }

  Future<PomodoroConfig> loadConfigOrDefault(PomodoroConfig defaults) async {
    final p = await _p;
    return defaults.copyWith(
      focusMinutes: p.getInt(_kFocusMins) ?? defaults.focusMinutes,
      shortBreakMinutes: p.getInt(_kShortMins) ?? defaults.shortBreakMinutes,
      longBreakMinutes: p.getInt(_kLongMins) ?? defaults.longBreakMinutes,
      cyclesPerLongBreak:
          p.getInt(_kCyclesPerLong) ?? defaults.cyclesPerLongBreak,
      dailyTargetCycles: p.getInt(_kDailyTarget) ?? defaults.dailyTargetCycles,
      autoStartNext: p.getBool(_kAutoStartNext) ?? defaults.autoStartNext,
    );
  }
}
