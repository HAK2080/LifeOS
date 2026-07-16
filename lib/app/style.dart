import 'package:flutter/material.dart';

/// Life design tokens: Nominal-inspired ink, paper, and acid-lime contrast.
/// The structure is confident and editorial without adding pressure mechanics.
abstract final class AppColors {
  static const accent = Color(0xFFD7FF4F);
  static const accentDeep = Color(0xFF8FAF17);

  // Light
  static const lightBg = Color(0xFFF5F6F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPanel = Color(0xFFEAF3C9);
  static const lightBorder = Color(0xFFD9DED1);
  static const lightText = Color(0xFF121712);
  static const lightText2 = Color(0xFF687064);

  // Dark (warm charcoal, like Claude dark mode)
  static const darkBg = Color(0xFF0B0E0C);
  static const darkSurface = Color(0xFF141914);
  static const darkPanel = Color(0xFF1D261B);
  static const darkBorder = Color(0xFF303A2D);
  static const darkText = Color(0xFFF1F5E9);
  static const darkText2 = Color(0xFFA9B2A4);
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
        borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Compact editorial section label. Arabic uses Naskh.
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
        fontFamily: arabic ? 'Naskh' : 'Sans',
        fontSize: arabic ? 18 : 12,
        letterSpacing: arabic ? 0 : 1.2,
        fontWeight: FontWeight.w600,
        color: arabic ? AppColors.accentDeep : Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.3,
      ),
    );
  }
}
