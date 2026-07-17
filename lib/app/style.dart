import 'package:flutter/material.dart';

/// Nominal-inspired design tokens: ink, paper, and mint.
/// Flat surfaces, hairline borders, ink-primary actions, mint highlights.
abstract final class AppColors {
  /// Mint highlight — used for selection, progress, and emphasis panels.
  static const accent = Color(0xFFA6F1C0);

  /// Deep green — links, active labels, anything that needs contrast on paper.
  static const accentDeep = Color(0xFF157A43);

  /// Ink — the primary action color in light mode (black buttons, Nominal-style).
  static const ink = Color(0xFF101312);

  // Light — warm paper
  static const lightBg = Color(0xFFF6F5F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPanel = Color(0xFFE4F8EC);
  static const lightBorder = Color(0xFFDCDDD5);
  static const lightText = Color(0xFF101312);
  static const lightText2 = Color(0xFF6A716C);

  // Dark — near-black ink with a green undertone
  static const darkBg = Color(0xFF0A0D0C);
  static const darkSurface = Color(0xFF121615);
  static const darkPanel = Color(0xFF16241C);
  static const darkBorder = Color(0xFF2A322D);
  static const darkText = Color(0xFFF2F4EF);
  static const darkText2 = Color(0xFFA3ACA6);
}

extension AppPalette on ColorScheme {
  bool get _dark => brightness == Brightness.dark;
  Color get panel => _dark ? AppColors.darkPanel : AppColors.lightPanel;
  Color get border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text2 => _dark ? AppColors.darkText2 : AppColors.lightText2;
}

/// Flat editorial card: hairline border, sharp-ish corners, no shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.tinted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tinted ? scheme.panel : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Nominal-style section label: small caps, wide tracking. Arabic uses Naskh.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.arabic = false});

  final String text;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      arabic ? text : text.toUpperCase(),
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        fontFamily: arabic ? 'Naskh' : 'Sans',
        fontSize: arabic ? 18 : 11.5,
        letterSpacing: arabic ? 0 : 1.6,
        fontWeight: arabic ? FontWeight.w600 : FontWeight.w700,
        color: arabic ? AppColors.accentDeep : scheme.onSurfaceVariant,
        height: 1.3,
      ),
    );
  }
}
