import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pomodoro_controller.dart';
import '../../domain/pomodoro_state.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);

    String title = switch (state.phase) {
      PomodoroPhase.focus => 'Foco',
      PomodoroPhase.shortBreak => 'Pausa curta',
      PomodoroPhase.longBreak => 'Pausa longa',
      PomodoroPhase.idle => 'Pronto',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(_mmss(state.secondsLeft),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: ctrl.startFocus,
                      child: const Text('Start foco')),
                  ElevatedButton(
                      onPressed: ctrl.startShortBreak,
                      child: const Text('Pausa curta')),
                  ElevatedButton(
                      onPressed: ctrl.startLongBreak,
                      child: const Text('Pausa longa')),
                  if (state.running)
                    ElevatedButton(
                        onPressed: ctrl.pause, child: const Text('Pausar'))
                  else
                    ElevatedButton(
                        onPressed: ctrl.resume, child: const Text('Retomar')),
                  ElevatedButton(
                      onPressed: ctrl.skip, child: const Text('Pular')),
                  OutlinedButton(
                      onPressed: ctrl.stop, child: const Text('Parar')),
                ]),
            const SizedBox(height: 16),
            Text('Ciclos de foco concluídos: ${state.completedFocusCycles}'),
          ],
        ),
      ),
    );
  }
}
