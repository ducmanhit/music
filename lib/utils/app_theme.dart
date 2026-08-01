import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

<<<<<<< HEAD
class AppColors {
  // Obsidian & Titanium Monochromatic Palette
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141417);
  static const Color surfaceElevated = Color(0xFF1E1E24);
  static const Color surfaceBorder = Color(0xFF26262E);

  // Elements & Controls
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF111113);
  static const Color secondarySurface = Color(0xFF22222A);

  // Typography
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF545458);

  // Status & Accents
  static const Color border = Color(0xFF1F1F24);
  static const Color activeHighlight = Color(0xFF2C2C36);
  static const Color error = Color(0xFFFF453A);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 0.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
=======
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
    canvas: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEAEDF1),
    surfaceStrong: Color(0xFFDDE2E8),
    border: Color(0xFFD8DDE3),
    textMuted: Color(0xFF676E78),
    textFaint: Color(0xFF9299A2),
    accentSoft: Color(0xFFE7EEFF),
    success: Color(0xFF17855C),
    warning: Color(0xFFB56A00),
    danger: Color(0xFFD33A42),
  );

  static const dark = AppTokens(
    canvas: Color(0xFF0E1114),
    surface: Color(0xFF171B1F),
    surfaceMuted: Color(0xFF20252A),
    surfaceStrong: Color(0xFF2A3036),
    border: Color(0xFF30363D),
    textMuted: Color(0xFFA5ACB5),
    textFaint: Color(0xFF767E88),
    accentSoft: Color(0xFF1B2A4C),
    success: Color(0xFF50C792),
    warning: Color(0xFFF1B24B),
    danger: Color(0xFFFF7178),
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
  }) {
    return AppTokens(
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
  }

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
      primary: const Color(0xFF2F66D8),
      onPrimary: Colors.white,
      text: const Color(0xFF171A1F),
    );

ThemeData buildDarkTheme() => _buildTheme(
      brightness: Brightness.dark,
      tokens: AppTokens.dark,
      primary: const Color(0xFF7CA2FF),
      onPrimary: const Color(0xFF07142E),
      text: const Color(0xFFF4F6F8),
    );

ThemeData _buildTheme({
  required Brightness brightness,
  required AppTokens tokens,
  required Color primary,
  required Color onPrimary,
  required Color text,
}) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  );
  final scheme = baseScheme.copyWith(
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
    visualDensity: VisualDensity.standard,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );

  final textTheme = base.textTheme.copyWith(
    displaySmall: base.textTheme.displaySmall?.copyWith(
      color: text,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      height: 1.04,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      color: text,
      fontWeight: FontWeight.w800,
      letterSpacing: -.8,
      height: 1.08,
    ),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      color: text,
      fontWeight: FontWeight.w700,
      letterSpacing: -.5,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      color: text,
      fontWeight: FontWeight.w700,
      letterSpacing: -.35,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      color: text,
      fontWeight: FontWeight.w700,
      letterSpacing: -.15,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      color: text,
      height: 1.35,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      color: text,
      height: 1.35,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: .05,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.canvas,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: tokens.border),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: tokens.border,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      hintStyle: TextStyle(color: tokens.textFaint),
      prefixIconColor: tokens.textMuted,
      suffixIconColor: tokens.textMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: tokens.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: tokens.surfaceStrong,
        disabledForegroundColor: tokens.textFaint,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: tokens.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: tokens.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: text,
        backgroundColor: Colors.transparent,
        highlightColor: primary.withValues(alpha: .10),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 66,
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: tokens.accentSoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected) ? primary : tokens.textMuted,
          fontSize: 11.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected) ? primary : tokens.textMuted,
          size: 23,
        );
      }),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shadowColor: Colors.transparent,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: tokens.border),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? const Color(0xFF25292E)
          : const Color(0xFFF0F2F4),
      contentTextStyle: TextStyle(
        color: brightness == Brightness.light ? Colors.white : const Color(0xFF111417),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: tokens.surfaceStrong,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: .12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: tokens.surface,
      selectedColor: tokens.accentSoft,
      disabledColor: tokens.surfaceMuted,
      side: BorderSide(color: tokens.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(color: text, fontWeight: FontWeight.w600),
      secondaryLabelStyle: TextStyle(color: primary, fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: tokens.textMuted,
      indicatorColor: primary,
      dividerColor: tokens.border,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tokens.textMuted,
      textColor: text,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 10,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
>>>>>>> f2ae42124e3a6e35c7f29ddeb1ab7ecd5b62ba21
}
