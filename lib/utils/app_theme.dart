import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// V10: giao diện sáng, phẳng và trung tính. Kính chỉ tạo độ trong/blur,
/// không dùng bóng, phản chiếu giả hoặc lớp màu tạo cảm giác 3D.
abstract final class AppColors {
  static const background = Color(0xFFF7F7F9);
  static const backgroundSoft = Color(0xFFFBFBFC);
  static const surface = Color(0x12FFFFFF);
  static const surfaceRaised = Color(0x8CFFFFFF);
  static const search = Color(0xA6FFFFFF);
  static const line = Color(0x183C3C43);
  static const lineStrong = Color(0x2E3C3C43);
  static const accent = Color(0xFF007AFF);
  static const accentBright = Color(0xFF409CFF);
  static const accentDark = Color(0x12007AFF);
  static const graphite = Color(0xFF1C1C1E);
  static const graphiteSoft = Color(0xFF48484A);

  // Giữ tên cũ để các màn hình không lỗi khi cập nhật patch.
  static const cyan = Color(0xFFF2F2F7);
  static const violet = Color(0xFFF2F2F7);
  static const pink = Color(0xFFF7F7F9);

  static const text = Color(0xFF111113);
  static const muted = Color(0xFF6E6E73);
  static const mutedSoft = Color(0xFF9A9AA0);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);
  static const ink = Colors.white;
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.text,
    error: AppColors.danger,
  );

  final base = ThemeData.light(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: '.SF Pro Text',
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    visualDensity: VisualDensity.standard,
    fontFamily: '.SF Pro Text',
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w700,
        letterSpacing: -1.25,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w700,
        letterSpacing: -.9,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
      ),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: Colors.transparent,
      barBackgroundColor: Colors.transparent,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: AppColors.text,
          fontFamily: '.SF Pro Text',
        ),
        navTitleTextStyle: TextStyle(
          color: AppColors.text,
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -.25,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: AppColors.text,
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.05,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontFamily: '.SF Pro Display',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -.75,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xB8FFFFFF),
      hintStyle: const TextStyle(
        color: AppColors.mutedSoft,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0x143C3C43), width: .7),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.accent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.accent,
        disabledBackgroundColor: const Color(0xFFD1D1D6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: Color(0x1F3C3C43), width: .7),
        backgroundColor: const Color(0xA8FFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.graphiteSoft,
      textColor: AppColors.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 10,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontFamily: '.SF Pro Text',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -.2,
      ),
      subtitleTextStyle: TextStyle(
        color: AppColors.muted,
        fontFamily: '.SF Pro Text',
        fontSize: 13.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x173C3C43),
      thickness: .65,
      space: 1,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: const Color(0x183C3C43),
      thumbColor: Colors.white,
      overlayColor: AppColors.accent.withValues(alpha: .05),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xF2FFFFFF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xE81C1C1E),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withValues(alpha: .94),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0x143C3C43), width: .7),
      ),
      textStyle: const TextStyle(
        color: AppColors.text,
        fontFamily: '.SF Pro Text',
        fontSize: 17,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.accent,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}

/// Nền sáng và phẳng. Ảnh bìa chỉ tạo một lớp màu rất nhẹ khi đang phát,
/// không có mảng gradient hoặc bóng giả.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child, this.artwork});

  final Widget child;
  final ImageProvider? artwork;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (artwork != null)
            Positioned.fill(
              child: Opacity(
                opacity: .028,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 82, sigmaY: 82),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      .33, .33, .33, 0, 28,
                      .33, .33, .33, 0, 28,
                      .33, .33, .33, 0, 28,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image(image: artwork!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Bề mặt kính phẳng: blur + màu trắng mỏng + viền trung tính. Không bóng,
/// không phản chiếu cạnh và không tạo cảm giác nổi 3D.
class GlassPanel extends StatefulWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.blur = 28,
    this.opacity = .18,
    this.onTap,
    this.shadow = true,
    this.tint,
    this.highlight = true,
    this.pressable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final VoidCallback? onTap;
  final bool shadow;
  final Color? tint;
  final bool highlight;
  final bool pressable;

  @override
  State<GlassPanel> createState() => _GlassPanelState();
}

class _GlassPanelState extends State<GlassPanel> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.pressable || widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final requested = widget.opacity.clamp(0.0, 1.0).toDouble();
    final baseAlpha = (0.035 + requested * .34).clamp(.035, .24).toDouble();
    final alpha = _pressed ? (baseAlpha + .035).clamp(0.0, .28) : baseAlpha;
    final tint = widget.tint ?? Colors.white;

    Widget surface = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: alpha),
            borderRadius: radius,
            border: Border.all(
              color: const Color(0x183C3C43),
              width: .65,
            ),
          ),
          padding: widget.padding ?? EdgeInsets.zero,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      surface = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: surface,
      );
    }
    return surface;
  }
}

class LiquidLens extends StatelessWidget {
  const LiquidLens({
    super.key,
    required this.child,
    this.borderRadius = 999,
    this.blur = 28,
    this.opacity = .16,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      shadow: false,
      highlight: false,
      pressable: false,
      child: child,
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox.square(
      dimension: size,
      child: GlassPanel(
        borderRadius: size / 2,
        blur: 32,
        opacity: selected ? .16 : .035,
        shadow: false,
        highlight: false,
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: size * .44,
            color: selected ? AppColors.accent : AppColors.graphite,
          ),
        ),
      ),
    );
    if (tooltip != null) result = Tooltip(message: tooltip!, child: result);
    return Opacity(opacity: onPressed == null ? .38 : 1, child: result);
  }
}
