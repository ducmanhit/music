import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// V9 dùng nền trắng trung tính và vật liệu kính cực trong. Màu xanh hệ thống
/// chỉ dùng cho trạng thái được chọn và hành động chính.
abstract final class AppColors {
  static const background = Color(0xFFF8F8FA);
  static const backgroundSoft = Color(0xFFFCFCFD);
  static const surface = Color(0x24FFFFFF);
  static const surfaceRaised = Color(0x52FFFFFF);
  static const search = Color(0x32FFFFFF);
  static const line = Color(0x5EFFFFFF);
  static const lineStrong = Color(0xCCFFFFFF);
  static const accent = Color(0xFF007AFF);
  static const accentBright = Color(0xFF4DA3FF);
  static const accentDark = Color(0x15007AFF);
  static const graphite = Color(0xFF151517);
  static const graphiteSoft = Color(0xFF3A3A3C);

  // Tên cũ được giữ để các màn hình hiện tại không bị lỗi khi cập nhật patch.
  static const cyan = Color(0xFFF1F2F5);
  static const violet = Color(0xFFEDEEF2);
  static const pink = Color(0xFFF8F8FA);

  static const text = Color(0xFF101012);
  static const muted = Color(0xFF6E6E73);
  static const mutedSoft = Color(0xFF98989E);
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
        letterSpacing: -1.35,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w700,
        letterSpacing: -.45,
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
          letterSpacing: -1.1,
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
        letterSpacing: -.8,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .34),
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
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .70)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: .96),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.accent,
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
        side: BorderSide(color: Colors.white.withValues(alpha: .78)),
        backgroundColor: Colors.white.withValues(alpha: .18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
      inactiveTrackColor: const Color(0x1A3C3C43),
      thumbColor: Colors.white,
      overlayColor: AppColors.accent.withValues(alpha: .06),
      trackHeight: 3.2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      elevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xE6FFFFFF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xE81C1C1E),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withValues(alpha: .86),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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

/// Nền trắng sạch. Không dùng gradient và không phủ hạt nhiễu. Các mảng mờ
/// trung tính chỉ tạo đủ chiều sâu để kính có thứ để khúc xạ.
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
          const Positioned(
            top: -170,
            right: -150,
            child: _AmbientBlur(
              width: 390,
              height: 360,
              color: Color(0xFFFFFFFF),
              opacity: .90,
            ),
          ),
          const Positioned(
            left: -210,
            top: 300,
            child: _AmbientBlur(
              width: 430,
              height: 500,
              color: Color(0xFFEFF0F4),
              opacity: .48,
            ),
          ),
          const Positioned(
            right: -180,
            bottom: -130,
            child: _AmbientBlur(
              width: 390,
              height: 390,
              color: Color(0xFFFFFFFF),
              opacity: .80,
            ),
          ),
          if (artwork != null)
            Positioned.fill(
              child: Opacity(
                opacity: .075,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 76, sigmaY: 76),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      .33, .33, .33, 0, 26,
                      .33, .33, .33, 0, 26,
                      .33, .33, .33, 0, 26,
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

/// Vật liệu kính V9: blur nền + một lớp trắng rất mỏng + viền phản chiếu.
/// Không dùng gradient đen/trắng bên trong nên bề mặt sạch và không bị bẩn.
class GlassPanel extends StatefulWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
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
    final materialAlpha = (0.045 + requested * .42).clamp(.06, .34).toDouble();
    final tint = widget.tint ?? Colors.white;

    Widget surface = AnimatedScale(
      scale: _pressed ? .986 : 1,
      duration: const Duration(milliseconds: 145),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.shadow
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B7280).withValues(
                      alpha: _pressed ? .045 : .065,
                    ),
                    blurRadius: _pressed ? 20 : 30,
                    spreadRadius: -12,
                    offset: Offset(0, _pressed ? 8 : 14),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: .50),
                    blurRadius: 14,
                    spreadRadius: -9,
                    offset: const Offset(-4, -5),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tint.withValues(alpha: materialAlpha),
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .72),
                  width: .85,
                ),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  if (widget.highlight)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GlassEdgePainter(
                            radius: widget.borderRadius,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
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
      shadow: shadow,
      highlight: true,
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
        blur: 30,
        opacity: selected ? .24 : .10,
        shadow: selected,
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: size * .45,
            color: selected ? AppColors.accent : AppColors.graphite,
          ),
        ),
      ),
    );
    if (tooltip != null) result = Tooltip(message: tooltip!, child: result);
    return Opacity(opacity: onPressed == null ? .38 : 1, child: result);
  }
}

class _GlassEdgePainter extends CustomPainter {
  const _GlassEdgePainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final topPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .72);
    final topPath = Path()
      ..moveTo(radius * .48, 1.4)
      ..cubicTo(
        size.width * .27,
        .45,
        size.width * .54,
        .55,
        size.width * .74,
        2.2,
      );
    canvas.drawPath(topPath, topPaint);

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .38);
    final leftPath = Path()
      ..moveTo(1.6, radius * .64)
      ..cubicTo(.55, size.height * .34, .65, size.height * .57, 2.0, size.height * .75);
    canvas.drawPath(leftPath, leftPaint);

    final lowerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8E8E93).withValues(alpha: .10);
    final lowerPath = Path()
      ..moveTo(size.width * .38, size.height - 1.4)
      ..cubicTo(
        size.width * .58,
        size.height - .4,
        size.width * .78,
        size.height - .7,
        size.width - radius * .43,
        size.height - 2.0,
      );
    canvas.drawPath(lowerPath, lowerPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

class _AmbientBlur extends StatelessWidget {
  const _AmbientBlur({
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
  });

  final double width;
  final double height;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width),
          ),
        ),
      ),
    );
  }
}
