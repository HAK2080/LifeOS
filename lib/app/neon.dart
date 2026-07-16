import 'package:flutter/material.dart';

/// Neon gaming palette. One accent per module so every tab feels like
/// its own "level", on a shared near-black arena.
abstract final class Neon {
  static const bg = Color(0xFF07070F); // near-black, blue tint
  static const surface = Color(0xFF10101E); // card body
  static const surfaceHi = Color(0xFF1A1A30); // raised elements

  static const cyan = Color(0xFF00E5FF); // Tasks
  static const gold = Color(0xFFFFC94D); // Today / ayah
  static const lime = Color(0xFF9DFF2E); // good deeds / nutrition
  static const magenta = Color(0xFFFF2ED2); // focus / energy
  static const ember = Color(0xFFFF5E3A); // training
  static const violet = Color(0xFFA05CFF); // growth
  static const ice = Color(0xFFB8C7E0); // body text
  static const dim = Color(0xFF6B7694); // secondary text
}

/// Dark card with a neon edge and soft outer glow.
class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.accent,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final Color accent;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Neon.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: accent.withValues(alpha: 0.12),
          highlightColor: accent.withValues(alpha: 0.06),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section header that glows.
class NeonTitle extends StatelessWidget {
  const NeonTitle(this.text,
      {super.key, required this.accent, this.arabic = false});

  final String text;
  final Color accent;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        fontFamily: arabic ? 'Tajawal' : 'Orbitron',
        fontSize: arabic ? 18 : 14,
        fontWeight: FontWeight.w700,
        letterSpacing: arabic ? 0 : 2.5,
        color: accent,
        shadows: [
          Shadow(color: accent.withValues(alpha: 0.9), blurRadius: 12),
          Shadow(color: accent.withValues(alpha: 0.4), blurRadius: 28),
        ],
      ),
    );
  }
}

/// Glowing filled button in the section's accent.
class NeonButton extends StatelessWidget {
  const NeonButton(
      {super.key,
      required this.label,
      required this.accent,
      required this.onPressed,
      this.filled = true});

  final String label;
  final Color accent;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? FilledButton.styleFrom(
            backgroundColor: accent.withValues(alpha: 0.18),
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.8)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent.withValues(alpha: 0.4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 1),
          );
    return filled
        ? FilledButton(style: style, onPressed: onPressed, child: Text(label))
        : OutlinedButton(style: style, onPressed: onPressed, child: Text(label));
  }
}
