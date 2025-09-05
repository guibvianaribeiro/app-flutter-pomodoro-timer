import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/app_colors.dart';
import 'package:pomodoro_timer/core/widgets/digit_card.dart';
import 'package:pomodoro_timer/core/widgets/round_icon_button.dart';
import 'package:pomodoro_timer/features/timer/domain/pomodoro_controller.dart';
import 'package:pomodoro_timer/features/timer/domain/pomodoro_state.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  final List<int> quickMinutes = const [0, 5, 10, 15, 20];
  int selected = 5;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);

    final secondsDisplay = (state.running || state.secondsLeft > 0)
        ? state.secondsLeft
        : (state.phase == PomodoroPhase.focus ||
                state.phase == PomodoroPhase.idle)
            ? state.config.focusMinutes * 60
            : state.config.shortBreakMinutes * 60;

    final mm = _two(secondsDisplay ~/ 60);
    final ss = _two(secondsDisplay % 60);

    final title = switch (state.phase) {
      PomodoroPhase.focus => 'Foco',
      PomodoroPhase.shortBreak => 'Pausa curta',
      PomodoroPhase.longBreak => 'Pausa longa',
      PomodoroPhase.idle => 'Foco',
    };

    final breaksProgress =
        state.completedFocusCycles % state.config.cyclesPerLongBreak;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ctrl.stop();
              // volta para tempo configurado
              setState(() => selected = state.config.focusMinutes);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),

                // Dígitos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4),
                    DigitCard(text: mm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        ':',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: AppColors.cardText),
                      ),
                    ),
                    DigitCard(text: ss),
                    const SizedBox(width: 4),
                  ],
                ),

                const SizedBox(height: 18),

                // Chips 0/5/10/15/20
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: quickMinutes.map((m) {
                    final isSel = m == selected;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() => selected = m);
                        ctrl.setConfig(state.config.copyWith(focusMinutes: m));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSel ? AppColors.chipSelected : AppColors.chipBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.chipBorder),
                        ),
                        child: Text(
                          '$m',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: isSel ? AppColors.coral : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // Botão redondo Play/Pause
                RoundIconButton(
                  icon: state.running
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onPressed: () {
                    if (state.running) {
                      ctrl.pause();
                    } else {
                      // se está idle, inicia foco com a duração selecionada
                      if (state.phase == PomodoroPhase.idle) {
                        ctrl.setConfig(
                            state.config.copyWith(focusMinutes: selected));
                        ctrl.startFocus();
                      } else {
                        ctrl.resume();
                      }
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Counters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat(
                        context,
                        '$breaksProgress/${state.config.cyclesPerLongBreak}',
                        'Pausas'),
                    _stat(
                        context,
                        '${state.completedFocusCycles}/${state.config.dailyTargetCycles}',
                        'Ciclos'),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ],
    );
  }
}
