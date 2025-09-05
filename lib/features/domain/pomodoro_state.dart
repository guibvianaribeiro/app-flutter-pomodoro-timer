enum PomodoroPhase { idle, focus, shortBreak, longBreak }

class PomodoroConfig {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int cyclesPerLongBreak;
  final bool autoStartNext;

  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.cyclesPerLongBreak = 4,
    this.autoStartNext = false,
  });
}

class PomodoroState {
  final PomodoroPhase phase;
  final int secondsLeft;
  final int completedFocusCycles;
  final bool running;
  final PomodoroConfig config;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.secondsLeft = 0,
    this.completedFocusCycles = 0,
    this.running = false,
    this.config = const PomodoroConfig(),
  });

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? secondsLeft,
    int? completedFocusCycles,
    bool? running,
    PomodoroConfig? config,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      completedFocusCycles: completedFocusCycles ?? this.completedFocusCycles,
      running: running ?? this.running,
      config: config ?? this.config,
    );
  }
}
