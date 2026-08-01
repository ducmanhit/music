import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.backgroundRaised,
    required this.surface,
    required this.surfaceHigh,
    required this.surfacePressed,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.disabled,
    required this.accent,
    required this.accentText,
    required this.danger,
    required this.success,
  });

  final Color background;
  final Color backgroundRaised;
  final Color surface;
  final Color surfaceHigh;
  final Color surfacePressed;
  final Color divider;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color disabled;
  final Color accent;
  final Color accentText;
  final Color danger;
  final Color success;

  Color get canvas => background;
  Color get surfaceMuted => surfaceHigh;
  Color get surfaceStrong => surfacePressed;
  Color get textMuted => textSecondary;
  Color get textFaint => textTertiary;
  Color get accentSoft => surfaceHigh;
  Color get warning => const Color(0xFFFF9F0A);

  static const dark = AppTokens(
    background: Color(0xFF0A1020),
    backgroundRaised: Color(0xFF0D1426),
    surface: Color(0xFF111827),
    surfaceHigh: Color(0xFF182132),
    surfacePressed: Color(0xFF202A3F),
    divider: Color(0xFF263044),
    border: Color(0xFF22304B),
    textPrimary: Color(0xFFF7F7F8),
    textSecondary: Color(0xFFA6AFC0),
    textTertiary: Color(0xFF6E778A),
    disabled: Color(0xFF465166),
    accent: Color(0xFFF6F6F4),
    accentText: Color(0xFF111723),
    danger: Color(0xFFFF453A),
    success: Color(0xFF32D74B),
  );

  static const light = AppTokens(
    background: Color(0xFFF5F5F7),
    backgroundRaised: Color(0xFFFAFAFB),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF0F0F3),
    surfacePressed: Color(0xFFE8E8EC),
    divider: Color(0xFFE0E0E5),
    border: Color(0xFFD8D8DE),
    textPrimary: Color(0xFF111114),
    textSecondary: Color(0xFF686870),
    textTertiary: Color(0xFF96969E),
    disabled: Color(0xFFB7B7BD),
    accent: Color(0xFF17171A),
    accentText: Color(0xFFFFFFFF),
    danger: Color(0xFFFF3B30),
    success: Color(0xFF34C759),
  );

  @override
  AppTokens copyWith({
    Color? background,
    Color? backgroundRaised,
    Color? surface,
    Color? surfaceHigh,
    Color? surfacePressed,
    Color? divider,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? disabled,
    Color? accent,
    Color? accentText,
    Color? danger,
    Color? success,
  }) {
    return AppTokens(
      background: background ?? this.background,
      backgroundRaised: backgroundRaised ?? this.backgroundRaised,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      disabled: disabled ?? this.disabled,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      background: Color.lerp(background, other.background, t)!,
      backgroundRaised:
          Color.lerp(backgroundRaised, other.backgroundRaised, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfacePressed: Color.lerp(surfacePressed, other.surfacePressed, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

ThemeData buildDarkTheme() => _buildTheme(AppTokens.dark, Brightness.dark);
ThemeData buildLightTheme() => _buildTheme(AppTokens.light, Brightness.light);

ThemeData _buildTheme(AppTokens tokens, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.accent,
    brightness: brightness,
  ).copyWith(
    primary: tokens.accent,
    onPrimary: tokens.accentText,
    secondary: tokens.textPrimary,
    onSecondary: tokens.background,
    error: tokens.danger,
    onError: Colors.white,
    surface: tokens.surface,
    onSurface: tokens.textPrimary,
    outline: tokens.border,
    outlineVariant: tokens.divider,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: tokens.textPrimary,
    onInverseSurface: tokens.background,
    inversePrimary: tokens.background,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.background,
    canvasColor: tokens.background,
    splashFactory: InkRipple.splashFactory,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );

  final textTheme = base.textTheme.copyWith(
    displaySmall: base.textTheme.displaySmall?.copyWith(
      color: tokens.textPrimary,
      fontSize: 32,
      height: 1.18,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      color: tokens.textPrimary,
      fontSize: 25,
      height: 1.24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.65,
    ),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      color: tokens.textPrimary,
      fontSize: 20,
      height: 1.28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      color: tokens.textPrimary,
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      color: tokens.textPrimary,
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      color: tokens.textPrimary,
      fontSize: 16,
      height: 1.4,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      color: tokens.textSecondary,
      fontSize: 14,
      height: 1.4,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      color: tokens.textSecondary,
      fontSize: 12,
      height: 1.35,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      color: tokens.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      color: tokens.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      color: tokens.textTertiary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );

  RoundedRectangleBorder rounded(double radius, {Color? border}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border == null ? BorderSide.none : BorderSide(color: border),
    );
  }

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.background,
      foregroundColor: tokens.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 56,
      titleTextStyle: textTheme.titleMedium,
      iconTheme: IconThemeData(color: tokens.textPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: rounded(28, border: tokens.border),
    ),
    dividerTheme: DividerThemeData(
      color: tokens.divider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surfaceHigh,
      hintStyle: TextStyle(color: tokens.textTertiary),
      labelStyle: TextStyle(color: tokens.textSecondary),
      prefixIconColor: tokens.textSecondary,
      suffixIconColor: tokens.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: tokens.textSecondary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: tokens.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.accent,
        foregroundColor: tokens.accentText,
        disabledBackgroundColor: tokens.disabled,
        disabledForegroundColor: tokens.textTertiary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: rounded(18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.textPrimary,
        backgroundColor: tokens.surfaceHigh,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: BorderSide(color: tokens.border),
        shape: rounded(18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: tokens.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: rounded(16),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: tokens.textPrimary,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.surface,
      modalBackgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: rounded(24, border: tokens.border),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          brightness == Brightness.dark ? tokens.textPrimary : tokens.accent,
      contentTextStyle: TextStyle(
        color: brightness == Brightness.dark
            ? tokens.background
            : tokens.accentText,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: rounded(18),
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: tokens.textPrimary,
      inactiveTrackColor: tokens.divider,
      thumbColor: tokens.textPrimary,
      overlayColor: tokens.textPrimary.withValues(alpha: 0.08),
      trackHeight: 2.5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tokens.accentText
            : tokens.textTertiary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tokens.accent
            : tokens.surfacePressed,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      labelColor: tokens.textPrimary,
      unselectedLabelColor: tokens.textSecondary,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: tokens.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}
