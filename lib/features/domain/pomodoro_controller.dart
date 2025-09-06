import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';
import 'pomodoro_state.dart';
import '../../core/services/ticker_service.dart';
import 'package:pomodoro_timer/core/services/prefs_service.dart';

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController(this._ticker, this._prefs) : super(const PomodoroState()) {
    _loadConfig();
  }

  final TickerService _ticker;
  final PrefsService _prefs;
  StreamSubscription<int>? _sub;

  Future<void> _loadConfig() async {
    final loaded = await _prefs.loadConfigOrDefault(state.config);
    state = state.copyWith(config: loaded);
  }

  Future<void> _saveConfig() => _prefs.saveConfig(state.config);

  void startFocus() => _startPhase(
        PomodoroPhase.focus,
        state.config.focusMinutes * 60,
      );

  void startShortBreak() => _startPhase(
        PomodoroPhase.shortBreak,
        state.config.shortBreakMinutes * 60,
      );

  void startLongBreak() => _startPhase(
        PomodoroPhase.longBreak,
        state.config.longBreakMinutes * 60,
      );

  void toggle() {
    if (state.running) {
      pause();
    } else {
      if (state.secondsLeft > 0 && state.phase != PomodoroPhase.idle) {
        resume();
      } else {
        startFocus();
      }
    }
  }

  void pause() {
    _sub?.pause();
    state = state.copyWith(running: false);
  }

  void resume() {
    _sub?.resume();
    state = state.copyWith(running: true);
  }

  void reset() {
    _sub?.cancel();
    state = PomodoroState(config: state.config);
  }

  void skip() {
    _sub?.cancel();
    _onCycleFinished();
  }

  void _startPhase(PomodoroPhase phase, int seconds) {
    _sub?.cancel();
    state = state.copyWith(phase: phase, secondsLeft: seconds, running: true);

    _sub = _ticker.countdown(fromSeconds: seconds).listen((remaining) {
      state = state.copyWith(secondsLeft: remaining, running: true);
    }, onDone: _onCycleFinished);
  }

  void _onCycleFinished() {
    if (state.phase == PomodoroPhase.focus) {
      final nextCount = state.completedFocusCycles + 1;
      final isLong = nextCount % state.config.cyclesPerLongBreak == 0;

      state = state.copyWith(completedFocusCycles: nextCount, running: false);

      if (state.config.autoStartNext) {
        isLong ? startLongBreak() : startShortBreak();
      } else {
        state = state.copyWith(
          phase: isLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak,
          secondsLeft: 0,
          running: false,
        );
      }
    } else if (state.phase == PomodoroPhase.shortBreak ||
        state.phase == PomodoroPhase.longBreak) {
      if (state.config.autoStartNext) {
        startFocus();
      } else {
        state = state.copyWith(
          phase: PomodoroPhase.idle,
          running: false,
          secondsLeft: 0,
        );
      }
    } else {
      state = state.copyWith(phase: PomodoroPhase.idle, running: false);
    }
  }

  // ===== setters de configuração + persistência =====
  void setFocusMinutes(int minutes) {
    state = state.copyWith(
      config: state.config.copyWith(focusMinutes: minutes),
    );
    _saveConfig();
  }

  void setShortBreakMinutes(int minutes) {
    state = state.copyWith(
      config: state.config.copyWith(shortBreakMinutes: minutes),
    );
    _saveConfig();
  }

  void setLongBreakMinutes(int minutes) {
    state = state.copyWith(
      config: state.config.copyWith(longBreakMinutes: minutes),
    );
    _saveConfig();
  }

  void setCyclesPerLongBreak(int cycles) {
    state = state.copyWith(
      config: state.config.copyWith(cyclesPerLongBreak: cycles),
    );
    _saveConfig();
  }

  void setDailyTargetCycles(int cycles) {
    state = state.copyWith(
      config: state.config.copyWith(dailyTargetCycles: cycles),
    );
    _saveConfig();
  }

  void setAutoStartNext(bool v) {
    state = state.copyWith(
      config: state.config.copyWith(autoStartNext: v),
    );
    _saveConfig();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
  final ticker = ref.read(tickerServiceProvider);
  final prefs = ref.read(prefsServiceProvider);
  return PomodoroController(ticker, prefs);
});
