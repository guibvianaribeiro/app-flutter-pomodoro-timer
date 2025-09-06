import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_state.dart';
import '../../../core/services/ticker_service.dart';

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController(this._ticker) : super(const PomodoroState());

  final TickerService _ticker;
  StreamSubscription<int>? _sub;

  get reset => null;

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

  void pause() {
    _sub?.pause();
    state = state.copyWith(running: false);
  }

  void resume() {
    _sub?.resume();
    state = state.copyWith(running: true);
  }

  void stop() {
    _sub?.cancel();
    state = state.copyWith(
        phase: PomodoroPhase.idle, running: false, secondsLeft: 0);
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
            phase: PomodoroPhase.idle, running: false, secondsLeft: 0);
      }
    } else {
      state = state.copyWith(phase: PomodoroPhase.idle, running: false);
    }
  }

  void setConfig(PomodoroConfig config) {
    state = state.copyWith(config: config);
  }

  void setFocusMinutes(int minutes) {
    state = state.copyWith(
      config: state.config.copyWith(focusMinutes: minutes),
    );
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
  return PomodoroController(ticker);
});
