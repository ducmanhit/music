import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Bảng màu trung tính, gần với giao diện iOS sáng.
/// Chỉ dùng system blue cho trạng thái được chọn và hành động chính.
abstract final class AppColors {
  static const background = Color(0xFFF4F4F6);
  static const backgroundSoft = Color(0xFFFAFAFB);
  static const surface = Color(0x70FFFFFF);
  static const surfaceRaised = Color(0xA8FFFFFF);
  static const search = Color(0x66FFFFFF);
  static const line = Color(0x66FFFFFF);
  static const lineStrong = Color(0xCFFFFFFF);
  static const accent = Color(0xFF0A84FF);
  static const accentBright = Color(0xFF64D2FF);
  static const accentDark = Color(0x160A84FF);
  static const graphite = Color(0xFF111113);
  static const graphiteSoft = Color(0xFF3A3A3C);

  // Giữ tên cũ để các màn hình không bị lỗi khi cập nhật patch.
  static const cyan = Color(0xFFE9E9EC);
  static const violet = Color(0xFFE2E2E6);
  static const pink = Color(0xFFF5F5F7);

  static const text = Color(0xFF111113);
  static const muted = Color(0xFF6E6E73);
  static const mutedSoft = Color(0xFF9A9AA0);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);
  static const ink = Colors.white;
}

abstract final class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFCFCFD),
      Color(0xFFF6F6F8),
      Color(0xFFF0F0F3),
      Color(0xFFF8F8FA),
    ],
    stops: [0, .32, .72, 1],
  );

  static const accentSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xD9FFFFFF), Color(0x7AFFFFFF)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF161618), Color(0xFF343438)],
  );

  static const glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF8FFFFFF),
      Color(0xAFFFFFFF),
      Color(0x38FFFFFF),
      Color(0x88FFFFFF),
    ],
    stops: [0, .30, .72, 1],
  );
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.text,
    error: AppColors.danger,
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
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(color: AppColors.text),
        navLargeTitleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
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
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .48),
      hintStyle: const TextStyle(
        color: AppColors.mutedSoft,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .72)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .96), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.graphite,
        disabledBackgroundColor: const Color(0xFFD1D1D6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: BorderSide(color: Colors.white.withValues(alpha: .76)),
        backgroundColor: Colors.white.withValues(alpha: .26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.graphiteSoft,
      textColor: AppColors.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 10,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1A3C3C43),
      thickness: .7,
      space: 1,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.graphite,
      inactiveTrackColor: const Color(0x293C3C43),
      thumbColor: Colors.white,
      overlayColor: AppColors.graphite.withValues(alpha: .06),
      trackHeight: 3.5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xF2FFFFFF),
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xECFFFFFF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(34)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xE81C1C1E),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withValues(alpha: .92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      textStyle: const TextStyle(color: AppColors.text, fontSize: 17),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.text,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.text,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

/// Nền trắng trung tính với vài lớp xám rất nhẹ. Các lớp này chỉ để kính có
/// vật thể phía sau để làm mờ, không tạo hiệu ứng xanh tím hoặc neon.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child, this.artwork});

  final Widget child;
  final ImageProvider? artwork;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (artwork != null)
            Positioned.fill(
              child: Opacity(
                opacity: .10,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
                  child: Image(image: artwork!, fit: BoxFit.cover),
                ),
              ),
            ),
          const Positioned(
            top: -160,
            right: -170,
            child: _SoftLens(width: 420, height: 390, opacity: .22),
          ),
          const Positioned(
            left: -210,
            top: 330,
            child: _SoftLens(width: 470, height: 520, opacity: .15),
          ),
          const Positioned(
            right: -180,
            bottom: -120,
            child: _SoftLens(width: 430, height: 410, opacity: .12),
          ),
          const Positioned.fill(child: _FineNoise()),
          child,
        ],
      ),
    );
  }
}

/// Bề mặt kính mỏng: nền trắng bán trong suốt, blur rõ, viền sáng phía trên,
/// bóng đổ mềm. Không dùng tint màu và không dùng quầng sáng neon.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
    this.blur = 24,
    this.opacity = .42,
    this.onTap,
    this.shadow = true,
    this.tint,
    this.highlight = true,
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

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    Widget result = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .075),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: const Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble()),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: .72),
                width: .8,
              ),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                if (highlight)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: .34),
                              Colors.white.withValues(alpha: .05),
                              Colors.transparent,
                            ],
                            stops: const [0, .30, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(padding: padding ?? EdgeInsets.zero, child: child),
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: result,
      );
    }
    return result;
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
        blur: 22,
        opacity: selected ? .72 : .48,
        shadow: false,
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: size * .46,
            color: selected ? AppColors.accent : AppColors.graphite,
          ),
        ),
      ),
    );
    if (tooltip != null) result = Tooltip(message: tooltip!, child: result);
    return Opacity(opacity: onPressed == null ? .38 : 1, child: result);
  }
}

class _SoftLens extends StatelessWidget {
  const _SoftLens({
    required this.width,
    required this.height,
    required this.opacity,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 62, sigmaY: 62),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width),
          gradient: RadialGradient(
            colors: [
              const Color(0xFF8E8E93).withValues(alpha: opacity),
              const Color(0xFFD1D1D6).withValues(alpha: opacity * .46),
              Colors.transparent,
            ],
            stops: const [0, .48, 1],
          ),
        ),
      ),
    );
  }
}

class _FineNoise extends StatelessWidget {
  const _FineNoise();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _FineNoisePainter()),
    );
  }
}

class _FineNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x07000000);
    const step = 11.0;
    for (double y = 4; y < size.height; y += step) {
      final offset = ((y / step).round().isEven) ? 4.0 : 8.0;
      for (double x = offset; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), .34, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
