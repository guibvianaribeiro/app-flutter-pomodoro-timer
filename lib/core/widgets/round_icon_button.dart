import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.size = 88,
    this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: cs.onPrimary, size: size * 0.34),
          ),
        ),
      ),
    );
  }
}
