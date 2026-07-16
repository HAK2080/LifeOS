import 'package:flutter/material.dart';

import 'neon.dart';

/// Neon gaming theme: near-black arena, glowing accents, techno type.
/// Still calm — glow instead of noise, and never a red warning.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.dark(
    primary: Neon.cyan,
    onPrimary: Colors.black,
    secondary: Neon.magenta,
    onSecondary: Colors.black,
    tertiary: Neon.lime,
    surface: Neon.bg,
    onSurface: Neon.ice,
    surfaceContainerLow: Neon.surface,
    surfaceContainerHighest: Neon.surfaceHi,
    onSurfaceVariant: Neon.dim,
    outline: Neon.dim,
    error: Neon.gold, // errors stay quiet — amber, never red
    onError: Colors.black,
  );

  const body = 'Rajdhani';
  const display = 'Orbitron';
  // Arabic falls back to Tajawal wherever Orbitron/Rajdhani lack glyphs.
  const arabicFallback = ['Tajawal'];

  final textTheme = Typography.whiteMountainView
      .apply(
        bodyColor: Neon.ice,
        displayColor: Neon.ice,
        fontFamily: body,
        fontFamilyFallback: arabicFallback,
      )
      .copyWith(
        headlineSmall: const TextStyle(
            fontFamily: body,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w600,
            fontSize: 26,
            color: Neon.ice),
        titleLarge: const TextStyle(
            fontFamily: display,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 1.2,
            color: Neon.ice),
        titleMedium: const TextStyle(
            fontFamily: body,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Neon.ice),
        bodyLarge: const TextStyle(
            fontFamily: body,
            fontFamilyFallback: arabicFallback,
            fontSize: 17,
            height: 1.4,
            color: Neon.ice),
        bodyMedium: const TextStyle(
            fontFamily: body,
            fontFamilyFallback: arabicFallback,
            fontSize: 15.5,
            height: 1.4,
            color: Neon.ice),
        bodySmall: const TextStyle(
            fontFamily: body,
            fontFamilyFallback: arabicFallback,
            fontSize: 13.5,
            color: Neon.dim),
      );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Neon.bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Neon.bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
        color: Neon.ice,
        shadows: [
          Shadow(color: Neon.cyan.withValues(alpha: 0.8), blurRadius: 16),
        ],
      ),
      iconTheme: const IconThemeData(color: Neon.ice),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Neon.cyan.withValues(alpha: 0.35)),
      ),
      color: Neon.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Neon.cyan.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Neon.cyan.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Neon.cyan, width: 1.4),
      ),
      filled: true,
      fillColor: Neon.surface,
      hintStyle: const TextStyle(color: Neon.dim, fontFamily: body),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: Neon.cyan.withValues(alpha: 0.7), width: 1.6),
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Neon.cyan
              : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Neon.cyan : Neon.dim),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Neon.cyan.withValues(alpha: 0.3)
              : Neon.surfaceHi),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Neon.surfaceHi,
      side: BorderSide(color: Neon.cyan.withValues(alpha: 0.35)),
      labelStyle: const TextStyle(
          fontFamily: body,
          fontFamilyFallback: arabicFallback,
          color: Neon.ice,
          fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Neon.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Neon.cyan.withValues(alpha: 0.4)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Neon.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Neon.cyan.withValues(alpha: 0.4)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Neon.surfaceHi,
      contentTextStyle: const TextStyle(fontFamily: body, color: Neon.ice),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Neon.violet.withValues(alpha: 0.5)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: Neon.cyan.withValues(alpha: 0.15),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Neon.ice,
      iconColor: Neon.dim,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Neon.cyan.withValues(alpha: 0.18),
      foregroundColor: Neon.cyan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Neon.cyan),
      ),
    ),
  );
}
