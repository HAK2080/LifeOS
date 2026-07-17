import 'package:flutter/material.dart';

import 'style.dart';

/// Nominal-inspired theme: ink & paper with a mint signal color.
/// Flat, editorial, precise. Primary actions are ink in light mode and
/// mint in dark mode — always with high-contrast foregrounds.
/// Errors stay amber — never red.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final primary = dark ? AppColors.accent : AppColors.ink;
  final onPrimary = dark ? AppColors.ink : AppColors.darkText;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
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
    error: const Color(0xFFB8860B),
    onError: Colors.white,
  );

  const sans = 'Sans';
  const arabicFallback = ['Naskh'];
  final base = dark ? Typography.whiteMountainView : Typography.blackMountainView;
  final textTheme = base.apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
    fontFamily: sans,
    fontFamilyFallback: arabicFallback,
  ).copyWith(
    headlineSmall: TextStyle(
        fontFamily: sans,
        fontFamilyFallback: arabicFallback,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.15,
        letterSpacing: -0.6,
        color: scheme.onSurface),
    titleLarge: TextStyle(
        fontFamily: sans,
        fontFamilyFallback: arabicFallback,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.3,
        color: scheme.onSurface),
    titleMedium: TextStyle(
        fontFamily: sans,
        fontFamilyFallback: arabicFallback,
        fontWeight: FontWeight.w600,
        fontSize: 16.5,
        letterSpacing: -0.1,
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
    labelSmall: TextStyle(
        fontFamily: sans,
        fontFamilyFallback: arabicFallback,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.4,
        color: scheme.onSurfaceVariant),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: sans,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outline),
      ),
      color: scheme.surfaceContainerLow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: dark ? AppColors.accent : AppColors.ink, width: 1.5),
      ),
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontFamily: sans),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: scheme.onSurfaceVariant, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primary : Colors.transparent),
      checkColor: WidgetStatePropertyAll(onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? onPrimary : scheme.onSurfaceVariant),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primary : scheme.surfaceContainerHighest),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: AppColors.accent,
      side: BorderSide(color: scheme.outline),
      labelStyle: TextStyle(
          fontFamily: sans,
          fontFamilyFallback: arabicFallback,
          color: scheme.onSurface,
          fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(
          fontFamily: sans, color: AppColors.ink, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 15),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.ink),
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 15),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? AppColors.accent : AppColors.accentDeep,
        textStyle: const TextStyle(
            fontFamily: sans, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline),
      ),
      titleTextStyle: TextStyle(
          fontFamily: sans,
          fontFamilyFallback: arabicFallback,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: scheme.onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? AppColors.darkPanel : AppColors.ink,
      contentTextStyle: TextStyle(
          fontFamily: sans, color: dark ? AppColors.darkText : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurfaceVariant,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: AppColors.accent,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.ink
              : scheme.onSurfaceVariant)),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
          fontFamily: sans,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface)),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.onSurface,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: dark ? AppColors.accent : AppColors.ink,
      dividerColor: scheme.outline,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? AppColors.accent : AppColors.accentDeep),
  );
}
