import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_state.dart';

final prefsServiceProvider = Provider<PrefsService>((ref) => PrefsService());

class PrefsService {
  static const _kSeed = 'seed_argb32';

  static const _kFocusMin = 'cfg_focus_minutes';
  static const _kShortMin = 'cfg_short_break_minutes';
  static const _kLongMin = 'cfg_long_break_minutes';
  static const _kCyclesPerLong = 'cfg_cycles_per_long_break';
  static const _kDailyTarget = 'cfg_daily_target_cycles';

  static Future<void> setSeed(Color c) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSeed, c.toARGB32());
  }

  static Future<Color?> getSeed() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getInt(_kSeed);
    if (v == null) return null;
    return Color(v);
  }

  static Future<PomodoroConfig> loadConfigOrDefault() async {
    final sp = await SharedPreferences.getInstance();
    final focus = sp.getInt(_kFocusMin) ?? 25;
    final shortB = sp.getInt(_kShortMin) ?? 5;
    final longB = sp.getInt(_kLongMin) ?? 15;
    final cyclesPerLong = sp.getInt(_kCyclesPerLong) ?? 4;
    final dailyTarget = sp.getInt(_kDailyTarget) ?? 12;

    return PomodoroConfig(
      focusMinutes: focus,
      shortBreakMinutes: shortB,
      longBreakMinutes: longB,
      cyclesPerLongBreak: cyclesPerLong,
      dailyTargetCycles: dailyTarget,
    );
  }

  static Future<void> saveConfig(PomodoroConfig c) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kFocusMin, c.focusMinutes);
    await sp.setInt(_kShortMin, c.shortBreakMinutes);
    await sp.setInt(_kLongMin, c.longBreakMinutes);
    await sp.setInt(_kCyclesPerLong, c.cyclesPerLongBreak);
    await sp.setInt(_kDailyTarget, c.dailyTargetCycles);
  }

  static Future<void> setCyclesPerLongBreak(int x) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kCyclesPerLong, x);
  }

  static Future<int?> getCyclesPerLongBreak() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kCyclesPerLong);
  }

  static Future<void> setDailyTargetCycles(int x) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kDailyTarget, x);
  }

  static Future<int?> getDailyTargetCycles() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kDailyTarget);
  }
}
