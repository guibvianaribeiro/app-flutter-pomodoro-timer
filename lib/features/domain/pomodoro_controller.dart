import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_state.dart';
import 'package:pomodoro_timer/core/services/ticker_service.dart';
import 'package:pomodoro_timer/core/services/prefs_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_timer/core/services/notification_service.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController(this._ticker, this._ref) : super(const PomodoroState()) {
    _loadConfig();
  }

  final TickerService _ticker;
  StreamSubscription<int>? _sub;
  final Ref _ref;

  Future<void> _loadConfig() async {
    final loaded = await PrefsService.loadConfigOrDefault();
    state = state.copyWith(config: loaded);
  }

  Future<void> _saveConfig() => PrefsService.saveConfig(state.config);

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
    _applyWakelock();
  }

  void resume() {
    _sub?.resume();
    state = state.copyWith(running: true);
    _applyWakelock();
  }

  void reset() {
    _sub?.cancel();
    state = PomodoroState(config: state.config);
    _applyWakelock();
  }

  void skip() {
    _sub?.cancel();
    _onCycleFinished();
  }

  void _startPhase(PomodoroPhase phase, int seconds) {
    _sub?.cancel();
    state = state.copyWith(phase: phase, secondsLeft: seconds, running: true);

    _sub = _ticker.countdown(fromSeconds: seconds).listen(
      (remaining) {
        state = state.copyWith(secondsLeft: remaining, running: true);
      },
      onDone: _onCycleFinished,
    );
    _applyWakelock();
  }

  void _onCycleFinished() {
    if (state.phase == PomodoroPhase.focus) {
      final nextCount = state.completedFocusCycles + 1;
      final isLong = state.config.enableLongBreak &&
          (nextCount % state.config.cyclesPerLongBreak == 0);

      state = state.copyWith(completedFocusCycles: nextCount, running: false);

      _maybeNotify('Foco concluído',
          isLong ? 'Hora da pausa longa' : 'Hora da pausa curta', next: isLong ? 'long' : 'short');

      if (state.config.autoStartBreaks) {
        isLong && state.config.enableLongBreak
            ? startLongBreak()
            : startShortBreak();
      } else {
        state = state.copyWith(
          phase: isLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak,
          secondsLeft: 0,
          running: false,
        );
        _applyWakelock();
      }
    } else if (state.phase == PomodoroPhase.shortBreak ||
        state.phase == PomodoroPhase.longBreak) {
      _maybeNotify('Pausa concluída', 'Vamos voltar ao foco', next: 'focus');

      if (state.config.autoStartFocus) {
        startFocus();
      } else {
        state = state.copyWith(
          phase: PomodoroPhase.idle,
          running: false,
          secondsLeft: 0,
        );
        _applyWakelock();
      }
    } else {
      state = state.copyWith(phase: PomodoroPhase.idle, running: false);
      _applyWakelock();
    }
  }

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

  void setEnableLongBreak(bool v) {
    state = state.copyWith(
      config: state.config.copyWith(enableLongBreak: v),
    );
    _saveConfig();
  }

  void setAutoStartNext(bool v) {
    state = state.copyWith(
      config: state.config.copyWith(autoStartNext: v),
    );
    _saveConfig();
  }

  void setAutoStartBreaks(bool v) {
    state = state.copyWith(
      config: state.config.copyWith(autoStartBreaks: v),
    );
    _saveConfig();
  }

  void setAutoStartFocus(bool v) {
    state = state.copyWith(
      config: state.config.copyWith(autoStartFocus: v),
    );
    _saveConfig();
  }

  Future<void> _applyWakelock() async {
    // Evita erros de canal em plataformas sem suporte e durante hot reload
    if (kIsWeb) return;
    final keepOn = _ref.read(keepScreenOnProvider);
    try {
      if (state.running && keepOn) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Ignora falhas do plugin (ex.: ainda não registrado). Não deve travar o app.
    }
  }

  Future<void> _maybeNotify(String title, String body, {String? next}) async {
    final notify = await PrefsService.getNotificationsEnabled();
    final vibrate = await PrefsService.getVibrateEnabled();
    if (notify) {
      await NotificationService.showCycleFinished(
          title: title, body: body, nextPhase: next ?? 'focus');
    }
    if (vibrate) {
      HapticFeedback.heavyImpact();
    }
  }

  void addMinutesToCurrent(int m) {
    final extra = m * 60;
    if (state.secondsLeft > 0) {
      state = state.copyWith(secondsLeft: state.secondsLeft + extra);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>(
  (ref) {
    final ticker = ref.read(tickerServiceProvider);
    return PomodoroController(ticker, ref);
  },
);
