import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.border,
    required this.textMuted,
    required this.textFaint,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color border;
  final Color textMuted;
  final Color textFaint;
  final Color accentSoft;
  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppTokens(
    canvas: Color(0xFFF4F4F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0F0EE),
    surfaceStrong: Color(0xFFE5E5E1),
    border: Color(0xFFE2E2DE),
    textMuted: Color(0xFF6F706D),
    textFaint: Color(0xFF9A9B97),
    accentSoft: Color(0xFFEAEAE7),
    success: Color(0xFF21865F),
    warning: Color(0xFFB76D16),
    danger: Color(0xFFD84C55),
  );

  static const dark = AppTokens(
    canvas: Color(0xFF080809),
    surface: Color(0xFF121214),
    surfaceMuted: Color(0xFF19191C),
    surfaceStrong: Color(0xFF232327),
    border: Color(0xFF29292E),
    textMuted: Color(0xFFA6A6AD),
    textFaint: Color(0xFF6F7078),
    accentSoft: Color(0xFF25252A),
    success: Color(0xFF55C99A),
    warning: Color(0xFFE2A85B),
    danger: Color(0xFFFF6B76),
  );

  @override
  AppTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? border,
    Color? textMuted,
    Color? textFaint,
    Color? accentSoft,
    Color? success,
    Color? warning,
    Color? danger,
  }) => AppTokens(
        canvas: canvas ?? this.canvas,
        surface: surface ?? this.surface,
        surfaceMuted: surfaceMuted ?? this.surfaceMuted,
        surfaceStrong: surfaceStrong ?? this.surfaceStrong,
        border: border ?? this.border,
        textMuted: textMuted ?? this.textMuted,
        textFaint: textFaint ?? this.textFaint,
        accentSoft: accentSoft ?? this.accentSoft,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

ThemeData buildLightTheme() => _buildTheme(
      brightness: Brightness.light,
      tokens: AppTokens.light,
      primary: const Color(0xFF171719),
      onPrimary: Colors.white,
      text: const Color(0xFF171719),
    );

ThemeData buildDarkTheme() => _buildTheme(
      brightness: Brightness.dark,
      tokens: AppTokens.dark,
      primary: const Color(0xFFF1F1F3),
      onPrimary: const Color(0xFF111113),
      text: const Color(0xFFF4F4F6),
    );

ThemeData _buildTheme({
  required Brightness brightness,
  required AppTokens tokens,
  required Color primary,
  required Color onPrimary,
  required Color text,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  ).copyWith(
    primary: primary,
    onPrimary: onPrimary,
    surface: tokens.surface,
    onSurface: text,
    error: tokens.danger,
    outline: tokens.border,
    outlineVariant: tokens.border,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.canvas,
    canvasColor: tokens.canvas,
    splashFactory: InkRipple.splashFactory,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
  final textTheme = base.textTheme.copyWith(
    displaySmall: base.textTheme.displaySmall?.copyWith(color: text, fontWeight: FontWeight.w800, letterSpacing: -1.1),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(color: text, fontWeight: FontWeight.w800, letterSpacing: -.8),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(color: text, fontWeight: FontWeight.w700, letterSpacing: -.45),
    titleLarge: base.textTheme.titleLarge?.copyWith(color: text, fontWeight: FontWeight.w700, letterSpacing: -.3),
    titleMedium: base.textTheme.titleMedium?.copyWith(color: text, fontWeight: FontWeight.w700),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(color: text, height: 1.35),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(color: text, height: 1.35),
    labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );
  RoundedRectangleBorder rounded(double radius, {Color? border}) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: border == null ? BorderSide.none : BorderSide(color: border),
      );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.canvas,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
      iconTheme: IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: rounded(24, border: tokens.border),
    ),
    dividerTheme: DividerThemeData(color: tokens.border, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surfaceMuted,
      hintStyle: TextStyle(color: tokens.textFaint),
      prefixIconColor: tokens.textMuted,
      suffixIconColor: tokens.textMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: primary, width: 1.2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: rounded(18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: tokens.surfaceMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 52),
        side: BorderSide.none,
        shape: rounded(18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: text,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: tokens.surfaceStrong,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            color: states.contains(WidgetState.selected) ? text : tokens.textMuted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? text : tokens.textMuted,
            size: 23,
          )),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.surface,
      modalBackgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: rounded(28, border: tokens.border),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark ? const Color(0xFFF1F1F3) : const Color(0xFF151517),
      contentTextStyle: TextStyle(color: brightness == Brightness.dark ? const Color(0xFF151517) : Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: rounded(18),
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: tokens.surfaceStrong,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: .10),
      trackHeight: 3,
    ),
  );
}
