import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';
import 'package:pomodoro_timer/core/theme/app_theme.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_controller.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_state.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);

    final seed = ref.watch(seedColorProvider);
    final on = AppTheme.onForSeed(seed);

    final String title = switch (state.phase) {
      PomodoroPhase.focus => 'Foco',
      PomodoroPhase.shortBreak => 'Pausa curta',
      PomodoroPhase.longBreak => 'Pausa longa',
      _ => 'Pomodoro',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, '/help'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.reset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [0, 5, 10, 15, 20].map((m) {
                final isSel = state.config.focusMinutes == m;
                return GestureDetector(
                  onTap: () => ctrl.setConfig(
                    state.config.copyWith(focusMinutes: m),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.white : on.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSel
                          ? [
                              const BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4))
                            ]
                          : null,
                    ),
                    child: Text(
                      '$m',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isSel ? on : on.withOpacity(.80),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CounterBlock(
                  value:
                      '${state.completedFocusCycles ~/ state.config.cyclesPerLongBreak}/${state.config.cyclesPerLongBreak}',
                  label: 'Pausas',
                  onColor: on,
                ),
                _CounterBlock(
                  value:
                      '${state.completedFocusCycles}/${state.config.dailyTargetCycles}',
                  label: 'Ciclos',
                  onColor: on,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CounterBlock extends StatelessWidget {
  const _CounterBlock(
      {required this.value, required this.label, required this.onColor});
  final String value;
  final String label;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: onColor)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: onColor.withOpacity(.7))),
      ],
    );
  }
}
