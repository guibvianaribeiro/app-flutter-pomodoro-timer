import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/app_theme.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';
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
      _ => 'Iniciar',
    };

    final minutes = (state.secondsLeft ~/ 60);
    final seconds = (state.secondsLeft % 60);

    Future<void> pickCustomFocus() async {
      final v = await showDialog<int>(
        context: context,
        builder: (ctx) {
          int current = state.config.focusMinutes.clamp(1, 100);
          return StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Definir tempo (min)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      '$current min',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    min: 1,
                    max: 100,
                    divisions: 99,
                    value: current.toDouble(),
                    label: '$current',
                    onChanged: (val) => setState(() => current = val.round()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, current),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        },
      );
      if (v != null && v >= 1 && v <= 100) {
        ctrl.setFocusMinutes(v);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
          style: TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, '/prefs'),
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
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontFamily: 'Oswald', fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            _TimeDisplay(
                onColor: on, seed: seed, minutes: minutes, seconds: seconds),

            const SizedBox(height: 16),

            _DurationChips(
              seed: seed,
              selectedMinutes: state.config.focusMinutes,
              onSelect: (m) => ctrl.setFocusMinutes(m),
              onPickCustom: pickCustomFocus,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.unselectedPillBg(seed),
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 18, color: on.withAlpha(0xCC)),
                  const SizedBox(width: 6),
                  Text(
                    '${state.config.focusMinutes} min',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: on.withAlpha(0xCC),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            _PlayPause(
                seed: seed, running: state.running, onToggle: ctrl.toggle),

            const SizedBox(height: 36),

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

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({
    required this.onColor,
    required this.seed,
    required this.minutes,
    required this.seconds,
  });

  final Color onColor;
  final Color seed;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final available = screenW - 40 - 16;
    final cardW = available / 2;
    final w = cardW.clamp(120.0, 170.0);
    final h = w * 1.23;
    final digitsColor = AppTheme.digitsOnCard(seed);
    final textStyle = TextStyle(
      fontFamily: 'Oswald',
      fontWeight: FontWeight.w800,
      fontSize: w * 0.72,
      color: digitsColor,
      height: 1.0,
    );

    BoxDecoration cardBox() => BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.softShadow(seed),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: w,
          height: h,
          decoration: cardBox(),
          alignment: Alignment.center,
          child: Text(_two(minutes), style: textStyle),
        ),
        const SizedBox(width: 16),
        Container(
          width: w,
          height: h,
          decoration: cardBox(),
          alignment: Alignment.center,
          child: Text(_two(seconds), style: textStyle),
        ),
      ],
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}

class _DurationChips extends StatelessWidget {
  const _DurationChips({
    required this.seed,
    required this.selectedMinutes,
    required this.onSelect,
    required this.onPickCustom,
  });

  final Color seed;
  final int selectedMinutes;
  final ValueChanged<int> onSelect;
  final VoidCallback onPickCustom;

  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);

    Widget chip(int m) {
      final isSel = selectedMinutes == m;
      final bg = isSel
          ? AppTheme.selectedPillBg(seed)
          : AppTheme.unselectedPillBg(seed);
      final fg = isSel ? on : on.withAlpha(0xCC);

      return Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSel ? AppTheme.softShadow(seed) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: GestureDetector(
          onTap: () => onSelect(m),
          child: Text('$m',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: fg,
              )),
        ),
      );
    }

    final customBg = AppTheme.unselectedPillBg(seed);
    final customFg = on.withAlpha(0xCC);

    return Wrap(
      spacing: 12,
      children: [
        chip(5),
        chip(10),
        chip(15),
        chip(20),
        chip(25),
        GestureDetector(
          onTap: onPickCustom,
          child: Container(
            decoration: BoxDecoration(
              color: customBg,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Icon(Icons.timer_outlined, size: 18, color: customFg),
          ),
        ),
      ],
    );
  }
}

class _PlayPause extends StatelessWidget {
  const _PlayPause(
      {required this.seed, required this.running, required this.onToggle});

  final Color seed;
  final bool running;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);
    final bg = Color.alphaBlend(on.withAlpha(0x24), seed);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow(seed),
      ),
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onToggle,
          child: const Padding(
            padding: EdgeInsets.all(28),
            child: Icon(Icons.play_arrow_rounded,
                size: 32),
          ),
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
                fontFamily: 'Oswald',
                fontSize: 14,
                color: onColor.withAlpha(0xB3))),
      ],
    );
  }
}
