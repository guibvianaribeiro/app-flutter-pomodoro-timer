enum PomodoroPhase { idle, focus, shortBreak, longBreak }

class PomodoroConfig {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int cyclesPerLongBreak;
  final bool enableLongBreak;
  final bool autoStartNext;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final int dailyTargetCycles;

  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 20,
    this.cyclesPerLongBreak = 4,
    this.enableLongBreak = true,
    this.autoStartNext = false,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.dailyTargetCycles = 12,
  });

  PomodoroConfig copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? cyclesPerLongBreak,
    bool? enableLongBreak,
    bool? autoStartNext,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    int? dailyTargetCycles,
  }) {
    return PomodoroConfig(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      cyclesPerLongBreak: cyclesPerLongBreak ?? this.cyclesPerLongBreak,
      enableLongBreak: enableLongBreak ?? this.enableLongBreak,
      autoStartNext: autoStartNext ?? this.autoStartNext,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      dailyTargetCycles: dailyTargetCycles ?? this.dailyTargetCycles,
    );
  }
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
