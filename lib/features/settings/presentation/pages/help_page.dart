import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pomodoro_timer/core/theme/theme_provider.dart';
import 'package:pomodoro_timer/core/theme/app_theme.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_controller.dart';
import 'package:pomodoro_timer/core/services/prefs_service.dart';

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  return NotificationsEnabledNotifier();
});

final vibrateEnabledProvider =
    StateNotifierProvider<VibrateEnabledNotifier, bool>((ref) {
  return VibrateEnabledNotifier();
});

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  NotificationsEnabledNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    state = await PrefsService.getNotificationsEnabled();
  }
  Future<void> set(bool v) async {
    state = v;
    await PrefsService.setNotificationsEnabled(v);
  }
}

class VibrateEnabledNotifier extends StateNotifier<bool> {
  VibrateEnabledNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    state = await PrefsService.getVibrateEnabled();
  }
  Future<void> set(bool v) async {
    state = v;
    await PrefsService.setVibrateEnabled(v);
  }
}

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedColorProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);
    final state = ref.watch(pomodoroControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferências')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('OPÇÕES'),
            _TileSwitch(
              title: 'Auto iniciar pausas',
              subtitle: 'Começa a pausa automaticamente após o foco',
              value: state.config.autoStartBreaks,
              onChanged: (v) => ctrl.setAutoStartBreaks(v),
              icon: Icons.pause_circle_filled_rounded,
              seed: seed,
            ),
            const SizedBox(height: 12),
            _TileSwitch(
              title: 'Auto iniciar próximo ciclo',
              subtitle: 'Começa o foco automaticamente após a pausa',
              value: state.config.autoStartFocus,
              onChanged: (v) => ctrl.setAutoStartFocus(v),
              icon: Icons.play_circle_fill_rounded,
              seed: seed,
            ),
            const SizedBox(height: 12),
            _TileSwitch(
              title: 'Manter tela ligada',
              subtitle: 'Evita que a tela apague durante o timer',
              value: ref.watch(keepScreenOnProvider),
              onChanged: (v) => ref.read(keepScreenOnProvider.notifier).set(v),
              icon: Icons.screen_lock_portrait_rounded,
              seed: seed,
            ),
            const SizedBox(height: 12),
            _TileSwitch(
              title: 'Mostrar notificações ao finalizar um ciclo',
              subtitle: 'Exibe um alerta quando o tempo termina',
              value: ref.watch(notificationsEnabledProvider),
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).set(v),
              icon: Icons.notifications_active_rounded,
              seed: seed,
            ),
            const SizedBox(height: 12),
            _TileSwitch(
              title: 'Vibrar quando terminar',
              subtitle: 'Feedback para vibrar ao fim do ciclo',
              value: ref.watch(vibrateEnabledProvider),
              onChanged: (v) =>
                  ref.read(vibrateEnabledProvider.notifier).set(v),
              icon: Icons.vibration_rounded,
              seed: seed,
            ),
            const SizedBox(height: 24),
            const _SectionTitle('PAUSAS E METAS'),
            _TileSwitch(
              title: 'Pausa longa automática',
              subtitle: 'A cada ${state.config.cyclesPerLongBreak} pomodoros',
              value: state.config.enableLongBreak,
              onChanged: (v) => ctrl.setEnableLongBreak(v),
              icon: Icons.hourglass_bottom_rounded,
              seed: seed,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StepperCard(
                    title: 'PAUSAS',
                    value: state.config.cyclesPerLongBreak,
                    onDec: () => ctrl.setCyclesPerLongBreak(
                        (state.config.cyclesPerLongBreak - 1).clamp(2, 12)),
                    onInc: () => ctrl.setCyclesPerLongBreak(
                        (state.config.cyclesPerLongBreak + 1).clamp(2, 12)),
                    seed: seed,
                    unit: '×',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StepperCard(
                    title: 'CICLOS',
                    value: state.config.dailyTargetCycles,
                    onDec: () => ctrl.setDailyTargetCycles(
                        (state.config.dailyTargetCycles - 1).clamp(1, 30)),
                    onInc: () => ctrl.setDailyTargetCycles(
                        (state.config.dailyTargetCycles + 1).clamp(1, 30)),
                    seed: seed,
                    unit: '×',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('PAUSA CURTA E LONGA'),
            Row(
              children: [
                Expanded(
                  child: _StepperCard(
                    title: 'PAUSA CURTA',
                    value: state.config.shortBreakMinutes,
                    onDec: () => ctrl.setShortBreakMinutes(
                        (state.config.shortBreakMinutes - 1).clamp(1, 30)),
                    onInc: () => ctrl.setShortBreakMinutes(
                        (state.config.shortBreakMinutes + 1).clamp(1, 30)),
                    seed: seed,
                    unit: 'min',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StepperCard(
                    title: 'PAUSA LONGA',
                    value: state.config.longBreakMinutes,
                    onDec: () => ctrl.setLongBreakMinutes(
                        (state.config.longBreakMinutes - 1).clamp(1, 60)),
                    onInc: () => ctrl.setLongBreakMinutes(
                        (state.config.longBreakMinutes + 1).clamp(1, 60)),
                    seed: seed,
                    unit: 'min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('TEMAS DE COR'),
            _ColorGrid(
              selected: seed,
              onSelect: (c) => ref.read(seedColorProvider.notifier).set(c),
              seed: seed,
            ),
            const SizedBox(height: 24),
            const _SectionTitle('SOBRE O POMODORO'),
            _InfoCard(
              seed: seed,
              text:
                  'Pomodoro é uma técnica de foco em blocos de tempo. Trabalhe por um período (ex.: 25 min) e faça pausas curtas (5 min). A cada 4 ciclos, faça uma pausa longa (15–20 min).',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: style),
    );
  }
}

class _TileSwitch extends StatelessWidget {
  const _TileSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.seed,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final Color seed;

  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);
    final cardColor = Color.alphaBlend(on.withAlpha(0x24), seed);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _CircleIcon(icon: icon, seed: seed),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: on),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    color: on.withAlpha(0xB3)),
              ),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: on,
            activeTrackColor: on.withAlpha(0x3D),
            inactiveThumbColor: on,
            inactiveTrackColor: on.withAlpha(0x3D),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.seed});
  final IconData icon;
  final Color seed;
  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: on.withAlpha(0x3D),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: on, size: 20),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.title,
    required this.value,
    required this.onDec,
    required this.onInc,
    required this.seed,
    this.unit = '×',
  });

  final String title;
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final Color seed;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);
    final bg = Color.alphaBlend(on.withAlpha(0x24), seed);

    Widget roundBtn(IconData icon, VoidCallback onTap) => InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: on),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  color: on.withAlpha(0xCC))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              roundBtn(Icons.remove_rounded, onDec),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: on,
                ),
              ),
              roundBtn(Icons.add_rounded, onInc),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({
    required this.selected,
    required this.onSelect,
    required this.seed,
  });

  final Color selected;
  final ValueChanged<Color> onSelect;
  final Color seed;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFF45B5E),
      const Color(0xFF9A96D9),
      const Color(0xFF5C3C6C),
      const Color(0xFF3F6B86),
      const Color(0xFFF07F7C),
      const Color(0xFFFFB74D),
      const Color(0xFF9C7B57),
      const Color(0xFF455A64),
      const Color(0xFF1E88E5),
      const Color(0xFF00695C),
      const Color(0xFFFB8C00),
      const Color(0xFFA4D65E),
      const Color(0xFFA9D4DF),
      const Color(0xFF8FD087),
      const Color(0xFFA5B4B9),
      const Color(0xFFCDE3D1),
      const Color(0xFF26C6DA),
      const Color(0xFF7EC8B9),
      const Color(0xFFA1D7E7),
      const Color(0xFF22D87E),
    ];

    final on = AppTheme.onForSeed(seed);

    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(on.withAlpha(0x14), seed),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map((c) {
          final isSel = c.toARGB32() == selected.toARGB32();
          final checkColor = AppTheme.onForSeed(c);

          return GestureDetector(
            onTap: () => onSelect(c),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12, width: 1),
                boxShadow: isSel ? AppTheme.softShadow(c) : null,
              ),
              child: isSel
                  ? Center(
                      child:
                          Icon(Icons.check_circle, color: checkColor, size: 24),
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.seed, required this.text});
  final Color seed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final on = AppTheme.onForSeed(seed);
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(on.withAlpha(0x14), seed),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: on),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: 'Lato', color: on.withAlpha(0xE6)),
            ),
          ),
        ],
      ),
    );
  }
}
