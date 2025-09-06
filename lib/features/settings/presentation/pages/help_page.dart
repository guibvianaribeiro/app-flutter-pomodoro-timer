import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';

final notificationsEnabledProvider = StateProvider<bool>((_) => true);
final vibrateEnabledProvider = StateProvider<bool>((_) => true);

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedColorProvider);
    // Texto/ícones dinâmicos: escuro para seeds claras, branco para seeds escuras
    final bool isLightSeed = seed.computeLuminance() > 0.62;
    final Color on = isLightSeed ? const Color(0xFF263238) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda & Preferências')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('OPÇÕES'),
            _TileSwitch(
              title: 'Mostrar notificações ao finalizar um ciclo',
              subtitle: 'Exibe um alerta quando o Pomodoro termina',
              value: ref.watch(notificationsEnabledProvider),
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).state = v,
              icon: Icons.notifications_active_rounded,
              onColor: on,
            ),
            const SizedBox(height: 12),
            _TileSwitch(
              title: 'Vibrar quando terminar',
              subtitle: 'Feedback para vibrar ao fim do ciclo',
              value: ref.watch(vibrateEnabledProvider),
              onChanged: (v) =>
                  ref.read(vibrateEnabledProvider.notifier).state = v,
              icon: Icons.vibration_rounded,
              onColor: on,
            ),
            const SizedBox(height: 24),
            const _SectionTitle('TEMAS DE COR'),
            _ColorGrid(
              selected: seed,
              onSelect: (c) => ref.read(seedColorProvider.notifier).state = c,
              onColor: on,
            ),
            const SizedBox(height: 24),
            const _SectionTitle('SOBRE'),
            _TileButton(
              title: 'Sobre o app',
              subtitle: 'Informações e créditos',
              icon: Icons.info_rounded,
              onTap: () => _showAbout(context),
              onColor: on,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sobre o App'),
        content: const Text(
          'Aplicação de timer Pomodoro desenvolvida em Flutter.\n\n'
          'Este projeto começou como **portfólio** (versão legada v0.1.0-legacy) '
          'e agora está sendo reescrito com arquitetura por features, Riverpod e Material 3. '
          'Objetivo: ser um Pomodoro simples, acessível e agradável de usar.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
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
    required this.onColor,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final cardColor = onColor.withOpacity(.14);
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _CircleIcon(icon, onColor),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: onColor),
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: onColor.withOpacity(.7))),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: onColor,
            activeTrackColor: onColor.withOpacity(.24),
            inactiveThumbColor: onColor,
            inactiveTrackColor: onColor.withOpacity(.24),
          ),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final cardColor = onColor.withOpacity(.14);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          _CircleIcon(icon, onColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: onColor)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: onColor.withOpacity(.7)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: onColor.withOpacity(.7)),
        ]),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon(this.icon, this.onColor);
  final IconData icon;
  final Color onColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: onColor.withOpacity(.24), shape: BoxShape.circle),
      child: Icon(icon, color: onColor, size: 20),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid(
      {required this.selected, required this.onSelect, required this.onColor});
  final Color selected;
  final ValueChanged<Color> onSelect;
  final Color onColor;

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map(
          (c) {
            final isSel = (c.value == selected.value);
            // check escuro para cores claras; claro para cores escuras
            final check = (c.computeLuminance() > 0.62)
                ? const Color(0xDD000000)
                : Colors.white;

            return GestureDetector(
              onTap: () => onSelect(c),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: isSel
                    ? Center(
                        child: Icon(Icons.check_circle, color: check, size: 24),
                      )
                    : null,
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
