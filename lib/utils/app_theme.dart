import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Hệ màu V8: trung tính, sáng và ít màu. System blue chỉ xuất hiện ở
/// trạng thái được chọn hoặc hành động quan trọng, giống cách iOS dùng màu.
abstract final class AppColors {
  static const background = Color(0xFFF5F5F7);
  static const backgroundSoft = Color(0xFFFBFBFC);
  static const surface = Color(0x3DFFFFFF);
  static const surfaceRaised = Color(0x70FFFFFF);
  static const search = Color(0x38FFFFFF);
  static const line = Color(0x52FFFFFF);
  static const lineStrong = Color(0xBFFFFFFF);
  static const accent = Color(0xFF007AFF);
  static const accentBright = Color(0xFF5AC8FA);
  static const accentDark = Color(0x12007AFF);
  static const graphite = Color(0xFF111113);
  static const graphiteSoft = Color(0xFF3A3A3C);

  // Giữ tên cũ để patch không làm lỗi những màn hình chưa cần đổi.
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
      Color(0xFFF8F8FA),
      Color(0xFFF2F2F5),
      Color(0xFFF9F9FB),
    ],
    stops: [0, .30, .72, 1],
  );

  static const accentSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xBFFFFFFF), Color(0x3DFFFFFF)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF171719), Color(0xFF303034)],
  );

  /// Viền có độ sáng khác nhau theo hướng ánh sáng, tạo cảm giác vật liệu
  /// cong thay vì một đường viền trắng đều quanh card.
  static const glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFAFFFFFF),
      Color(0xAFFFFFFF),
      Color(0x2BFFFFFF),
      Color(0x18000000),
      Color(0x8FFFFFFF),
    ],
    stops: [0, .27, .56, .78, 1],
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
        letterSpacing: -1.4,
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
          letterSpacing: -1.15,
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
      fillColor: Colors.white.withValues(alpha: .20),
      hintStyle: const TextStyle(
        color: AppColors.mutedSoft,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: .82),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
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
        side: BorderSide(color: Colors.white.withValues(alpha: .56)),
        backgroundColor: Colors.white.withValues(alpha: .14),
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
      color: Color(0x183C3C43),
      thickness: .65,
      space: 1,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.graphite,
      inactiveTrackColor: const Color(0x243C3C43),
      thumbColor: Colors.white,
      overlayColor: AppColors.graphite.withValues(alpha: .045),
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
      backgroundColor: Color(0xC9FFFFFF),
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
      color: Colors.white.withValues(alpha: .78),
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
      labelColor: AppColors.text,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.text,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}

/// Nền sáng V8. Không tạo gradient xanh tím. Các vùng xám rất nhẹ phía sau
/// là lớp nội dung để vật liệu kính có chiều sâu khi blur.
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
                opacity: .16,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      .72, .18, .10, 0, 0,
                      .10, .80, .10, 0, 0,
                      .08, .18, .74, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image(image: artwork!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          const Positioned(
            top: -180,
            right: -160,
            child: _SoftLens(width: 430, height: 390, opacity: .19),
          ),
          const Positioned(
            left: -220,
            top: 320,
            child: _SoftLens(width: 480, height: 530, opacity: .13),
          ),
          const Positioned(
            right: -190,
            bottom: -120,
            child: _SoftLens(width: 440, height: 420, opacity: .10),
          ),
          const Positioned.fill(child: _FineNoise()),
          child,
        ],
      ),
    );
  }
}

/// Vật liệu kính lỏng mô phỏng bằng nhiều lớp: blur nền, lớp vật liệu mỏng,
/// viền khúc xạ theo hướng ánh sáng và các điểm phản chiếu cong. Widget có
/// phản hồi nhấn rất nhẹ để trông giống một vật thể nổi thay vì card tĩnh.
class GlassPanel extends StatefulWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
    this.blur = 22,
    this.opacity = .42,
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
    final materialAlpha = (0.075 + requested * .40)
        .clamp(.10, .44)
        .toDouble();
    final tint = widget.tint ?? Colors.white;

    Widget surface = AnimatedScale(
      scale: _pressed ? .985 : 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.shadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _pressed ? .055 : .080,
                    ),
                    blurRadius: _pressed ? 19 : 32,
                    spreadRadius: -10,
                    offset: Offset(0, _pressed ? 9 : 17),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: .42),
                    blurRadius: 16,
                    spreadRadius: -9,
                    offset: const Offset(-5, -6),
                  ),
                ]
              : null,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.glassBorder,
            borderRadius: radius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(.85),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                (widget.borderRadius - .85).clamp(0.0, double.infinity).toDouble(),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: materialAlpha),
                          borderRadius: radius,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: .24),
                              Colors.white.withValues(alpha: .055),
                              Colors.white.withValues(alpha: .015),
                              Colors.black.withValues(alpha: .025),
                            ],
                            stops: const [0, .28, .66, 1],
                          ),
                        ),
                      ),
                    ),
                    if (widget.highlight)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _LiquidSpecularPainter(
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

/// Thấu kính nhỏ dùng cho tab đang chọn và các nút điều khiển. Nó sáng hơn
/// GlassPanel nhưng vẫn nhìn xuyên được nền phía sau.
class LiquidLens extends StatelessWidget {
  const LiquidLens({
    super.key,
    required this.child,
    this.borderRadius = 999,
    this.blur = 18,
    this.opacity = .34,
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
        blur: 20,
        opacity: selected ? .48 : .25,
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

class _LiquidSpecularPainter extends CustomPainter {
  const _LiquidSpecularPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final topPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xD9FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width * .72, 20));

    final topPath = Path()
      ..moveTo(radius * .48, 1.7)
      ..cubicTo(
        size.width * .25,
        .3,
        size.width * .53,
        .7,
        size.width * .72,
        2.8,
      );
    canvas.drawPath(topPath, topPaint);

    final sidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .28);
    final sidePath = Path()
      ..moveTo(1.9, radius * .62)
      ..cubicTo(.5, size.height * .31, .7, size.height * .55, 2.2, size.height * .72);
    canvas.drawPath(sidePath, sidePaint);

    final causticPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = Colors.white.withValues(alpha: .16);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .60,
        size.height * .08,
        size.width * .29,
        size.height * .23,
      ),
      -.35,
      1.65,
      false,
      causticPaint,
    );

    final lowerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: .035);
    final lowerPath = Path()
      ..moveTo(size.width * .35, size.height - 1.8)
      ..cubicTo(
        size.width * .58,
        size.height - .5,
        size.width * .78,
        size.height - .8,
        size.width - radius * .42,
        size.height - 2.5,
      );
    canvas.drawPath(lowerPath, lowerPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidSpecularPainter oldDelegate) {
    return oldDelegate.radius != radius;
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
      imageFilter: ImageFilter.blur(sigmaX: 66, sigmaY: 66),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width),
          gradient: RadialGradient(
            colors: [
              const Color(0xFF8E8E93).withValues(alpha: opacity),
              const Color(0xFFD1D1D6).withValues(alpha: opacity * .43),
              Colors.transparent,
            ],
            stops: const [0, .46, 1],
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
    return IgnorePointer(child: CustomPaint(painter: _FineNoisePainter()));
  }
}

class _FineNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x05000000);
    const step = 12.0;
    for (double y = 4; y < size.height; y += step) {
      final offset = ((y / step).round().isEven) ? 4.0 : 8.0;
      for (double x = offset; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), .30, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
