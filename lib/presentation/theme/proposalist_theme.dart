import 'package:flutter/material.dart';

class ProposalistColors {
  const ProposalistColors._();

  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF2FF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const border = Color(0xFFCBD5E1);
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);
  static const accentSky = Color(0xFF0EA5E9);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
}

class ProposalistSpacing {
  const ProposalistSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

class ProposalistRadius {
  const ProposalistRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

ThemeData buildProposalistTheme() {
  const colorScheme = ColorScheme.light(
    primary: ProposalistColors.primary,
    secondary: ProposalistColors.accentSky,
    error: ProposalistColors.error,
    onSurface: ProposalistColors.textPrimary,
  );

  final baseTextTheme = Typography.blackCupertino.apply(
    fontFamily: 'Inter',
    bodyColor: ProposalistColors.textPrimary,
    displayColor: ProposalistColors.textPrimary,
  );

  final textTheme = baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: ProposalistColors.textSecondary,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
  );

  OutlineInputBorder outline(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(ProposalistRadius.md),
      borderSide: BorderSide(color: color),
    );
  }

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ProposalistColors.background,
    fontFamily: 'Inter',
    textTheme: textTheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: ProposalistColors.background,
      foregroundColor: ProposalistColors.textPrimary,
      centerTitle: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: ProposalistColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProposalistRadius.lg),
        side: const BorderSide(color: ProposalistColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ProposalistColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ProposalistSpacing.md,
        vertical: ProposalistSpacing.sm,
      ),
      border: outline(ProposalistColors.border),
      enabledBorder: outline(ProposalistColors.border),
      focusedBorder: outline(ProposalistColors.primary),
      errorBorder: outline(ProposalistColors.error),
      focusedErrorBorder: outline(ProposalistColors.error),
      labelStyle: textTheme.bodySmall,
      hintStyle: textTheme.bodySmall?.copyWith(
        color: ProposalistColors.textSecondary.withValues(alpha: 0.78),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: ProposalistColors.primary,
        foregroundColor: Colors.white,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProposalistRadius.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: ProposalistColors.textPrimary,
        side: const BorderSide(color: ProposalistColors.border),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProposalistRadius.md),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: ProposalistColors.surface,
      indicatorColor: ProposalistColors.surfaceAlt,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          fontSize: 10,
          color: selected
              ? ProposalistColors.primary
              : ProposalistColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected
              ? ProposalistColors.primary
              : ProposalistColors.textSecondary,
          size: 22,
        );
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ProposalistColors.primary,
      inactiveTrackColor: ProposalistColors.border,
      overlayColor: ProposalistColors.primary.withValues(alpha: 0.14),
      thumbColor: ProposalistColors.primary,
      trackHeight: 3,
    ),
  );
}
