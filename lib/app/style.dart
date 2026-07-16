import 'package:flutter/material.dart';

/// Claude-inspired design tokens: warm ivory light theme, warm charcoal
/// dark theme, one terracotta accent. Calm, mature, easy on the eyes.
abstract final class AppColors {
  // Shared accent (Claude terracotta)
  static const accent = Color(0xFFD97757);
  static const accentDeep = Color(0xFFC2603F);

  // Light
  static const lightBg = Color(0xFFFAF9F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPanel = Color(0xFFF0EEE6); // tinted panel (ayah card)
  static const lightBorder = Color(0xFFE3E0D5);
  static const lightText = Color(0xFF33322E);
  static const lightText2 = Color(0xFF75746C);

  // Dark (warm charcoal, like Claude dark mode)
  static const darkBg = Color(0xFF262624);
  static const darkSurface = Color(0xFF30302E);
  static const darkPanel = Color(0xFF383836);
  static const darkBorder = Color(0xFF45443F);
  static const darkText = Color(0xFFE8E6DF);
  static const darkText2 = Color(0xFFA6A49B);
}

/// Convenience accessors for the current brightness.
extension AppPalette on ColorScheme {
  bool get _dark => brightness == Brightness.dark;
  Color get panel => _dark ? AppColors.darkPanel : AppColors.lightPanel;
  Color get border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text2 => _dark ? AppColors.darkText2 : AppColors.lightText2;
}

/// Quiet card: soft surface, hairline border, gentle shadow. No glow.
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

  /// Tinted cards sit on the warm panel color instead of plain surface.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tinted ? scheme.panel : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: scheme.brightness == Brightness.dark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Serif section title in the accent, normal case. Arabic uses Naskh.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.arabic = false});

  final String text;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      style: TextStyle(
        fontFamily: arabic ? 'Naskh' : 'Serif',
        fontSize: arabic ? 18 : 17,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        height: 1.3,
      ),
    );
  }
}
