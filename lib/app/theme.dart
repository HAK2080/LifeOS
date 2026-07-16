import 'package:flutter/material.dart';

import 'style.dart';

/// Claude-inspired theme: warm neutrals, one terracotta accent,
/// serif headings, quiet borders. Errors stay amber — never red.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.accent,
    onPrimary: Colors.white,
    secondary: AppColors.accentDeep,
    onSecondary: Colors.white,
    tertiary: dark ? AppColors.darkText2 : AppColors.lightText2,
    onTertiary: dark ? AppColors.darkBg : AppColors.lightBg,
    surface: dark ? AppColors.darkBg : AppColors.lightBg,
    onSurface: dark ? AppColors.darkText : AppColors.lightText,
    surfaceContainerLow: dark ? AppColors.darkSurface : AppColors.lightSurface,
    surfaceContainerHighest: dark ? AppColors.darkPanel : AppColors.lightPanel,
    onSurfaceVariant: dark ? AppColors.darkText2 : AppColors.lightText2,
    outline: dark ? AppColors.darkBorder : AppColors.lightBorder,
    error: const Color(0xFFB8860B), // quiet amber
    onError: Colors.white,
  );

  const sans = 'Sans';
  const arabicFallback = ['Naskh'];

  final base = dark ? Typography.whiteMountainView : Typography.blackMountainView;
  final textTheme = base
      .apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
        fontFamily: sans,
        fontFamilyFallback: arabicFallback,
      )
      .copyWith(
        headlineSmall: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w600,
            fontSize: 24,
            height: 1.3,
            color: scheme.onSurface),
        titleLarge: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: scheme.onSurface),
        titleMedium: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w600,
            fontSize: 16.5,
            color: scheme.onSurface),
        bodyLarge: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontSize: 16.5,
            height: 1.5,
            color: scheme.onSurface),
        bodyMedium: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontSize: 15,
            height: 1.5,
            color: scheme.onSurface),
        bodySmall: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontSize: 13,
            height: 1.4,
            color: scheme.onSurfaceVariant),
        labelLarge: TextStyle(
            fontFamily: sans,
            fontFamilyFallback: arabicFallback,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: scheme.onSurface),
      );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: sans,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      color: scheme.surfaceContainerLow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontFamily: sans),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: scheme.onSurfaceVariant, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : scheme.onSurfaceVariant),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? AppColors.accent
              : scheme.surfaceContainerHighest),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      side: BorderSide(color: scheme.outline),
      labelStyle: TextStyle(
          fontFamily: sans,
          fontFamilyFallback: arabicFallback,
          color: scheme.onSurface,
          fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentDeep,
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outline),
      ),
      titleTextStyle: TextStyle(
          fontFamily: sans,
          fontFamilyFallback: arabicFallback,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? AppColors.darkPanel : AppColors.lightText,
      contentTextStyle: TextStyle(
          fontFamily: sans,
          color: dark ? AppColors.darkText : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(color: scheme.outline),
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurfaceVariant,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.accent),
  );
}
