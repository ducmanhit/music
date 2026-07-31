import 'dart:ui';

import 'package:flutter/material.dart';

/// Neutral iOS-inspired palette. Saturated colours are deliberately limited to
/// the system blue used for selected states and primary actions.
abstract final class AppColors {
  static const background = Color(0xFFF2F2F7);
  static const backgroundSoft = Color(0xFFF8F8FA);
  static const surface = Color(0x8FFFFFFF);
  static const surfaceRaised = Color(0xC7FFFFFF);
  static const search = Color(0xA8FFFFFF);
  static const line = Color(0x8FFFFFFF);
  static const lineStrong = Color(0xD9FFFFFF);
  static const accent = Color(0xFF007AFF);
  static const accentBright = Color(0xFF5AC8FA);
  static const accentDark = Color(0x14007AFF);
  static const graphite = Color(0xFF1C1C1E);
  static const graphiteSoft = Color(0xFF3A3A3C);

  // Kept for API compatibility with older screens. These are intentionally
  // neutral so no cyan/violet/pink cast leaks into the glass surfaces.
  static const cyan = Color(0xFFEDEDEF);
  static const violet = Color(0xFFE5E5EA);
  static const pink = Color(0xFFF5F5F7);

  static const text = Color(0xFF111114);
  static const muted = Color(0xFF6E6E73);
  static const mutedSoft = Color(0xFF9A9AA0);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);
  static const ink = Colors.white;
}

abstract final class AppGradients {
  /// Quiet neutral canvas, close to the iOS grouped background.
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBFBFC),
      Color(0xFFF2F2F6),
      Color(0xFFECECF1),
      Color(0xFFF7F7F9),
    ],
    stops: [0, .38, .74, 1],
  );

  static const accentSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEFFFFFFF), Color(0x9AFFFFFF), Color(0x70EAEAEE)],
  );

  /// Used by a few hero elements that expect white foreground content.
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF151517), Color(0xFF2C2C2E)],
  );

  static const glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xB8FFFFFF),
      Color(0x58FFFFFF),
      Color(0x9AFFFFFF),
    ],
    stops: [0, .34, .70, 1],
  );
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    primary: AppColors.accent,
    surface: Colors.white.withValues(alpha: .78),
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: scheme,
    fontFamily: '.SF Pro Display',
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 67,
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.white.withValues(alpha: .86),
      elevation: 0,
      shadowColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.graphiteSoft,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.graphiteSoft,
          size: 24,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.search,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.mutedSoft),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: const BorderSide(color: AppColors.lineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(23),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.accent,
        disabledBackgroundColor: const Color(0xFFD5D5DA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.lineStrong),
        backgroundColor: Colors.white.withValues(alpha: .45),
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
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.graphiteSoft,
      textColor: AppColors.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
    ),
    dividerTheme: const DividerThemeData(color: Color(0x16787880), thickness: 1),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.graphite,
      inactiveTrackColor: const Color(0x33787880),
      thumbColor: Colors.white,
      overlayColor: AppColors.graphite.withValues(alpha: .08),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xEAF7F7F9),
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xEFF9F9FA),
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
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
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textStyle: const TextStyle(color: AppColors.text),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.accent,
      dividerColor: Color(0x16787880),
      labelStyle: TextStyle(fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}

/// Neutral background with enough luminance variation for the backdrop blur to
/// look like real glass, without coloured aurora blobs.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -120,
            right: -100,
            child: _NeutralOrb(
              width: 330,
              height: 320,
              colors: [Color(0xFFFFFFFF), Color(0x80D9D9DE)],
              angle: .22,
            ),
          ),
          const Positioned(
            left: -180,
            top: 245,
            child: _NeutralOrb(
              width: 390,
              height: 430,
              colors: [Color(0xBFFFFFFF), Color(0x6AC7C7CC)],
              angle: -.38,
            ),
          ),
          const Positioned(
            right: -150,
            bottom: 35,
            child: _NeutralOrb(
              width: 360,
              height: 390,
              colors: [Color(0xAFFFFFFF), Color(0x5AB8B8BE)],
              angle: .48,
            ),
          ),
          const Positioned(
            left: 85,
            bottom: -170,
            child: _NeutralOrb(
              width: 320,
              height: 310,
              colors: [Color(0xCFFFFFFF), Color(0x34AEAEB4)],
              angle: -.16,
            ),
          ),
          const Positioned.fill(child: _OpticalVeil()),
          child,
        ],
      ),
    );
  }
}

/// Reusable neutral liquid-glass surface with strong blur, a glossy upper rim,
/// subtle lower refraction and a physically softer shadow.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.blur = 30,
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
    final refractiveTint = tint ?? AppColors.graphite;

    Widget panel = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.glassBorder,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: const Color(0xFF3A3A3C).withValues(alpha: .11),
                  blurRadius: 34,
                  spreadRadius: -10,
                  offset: const Offset(0, 19),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: .74),
                  blurRadius: 12,
                  spreadRadius: -6,
                  offset: const Offset(-5, -5),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(1.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (borderRadius - 1.1).clamp(0, 999).toDouble(),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1.0, -1.15),
                      end: const Alignment(1.0, 1.05),
                      colors: [
                        Colors.white.withValues(alpha: (opacity + .20).clamp(0, 1).toDouble()),
                        Colors.white.withValues(alpha: opacity * .82),
                        const Color(0xFFE5E5EA).withValues(alpha: opacity * .30),
                        Colors.white.withValues(alpha: opacity * .68),
                      ],
                      stops: const [0, .34, .72, 1],
                    ),
                  ),
                ),
              ),
              if (highlight) ...[
                Positioned(
                  left: -borderRadius * .42,
                  top: -borderRadius * .84,
                  width: borderRadius * 4.6,
                  height: borderRadius * 2.7,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius * 2.2),
                        gradient: RadialGradient(
                          center: const Alignment(-.28, -.42),
                          radius: .86,
                          colors: [
                            Colors.white.withValues(alpha: .78),
                            Colors.white.withValues(alpha: .20),
                            Colors.transparent,
                          ],
                          stops: const [0, .48, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -borderRadius * 1.0,
                  bottom: -borderRadius * 1.24,
                  width: borderRadius * 4.7,
                  height: borderRadius * 3.25,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius * 2.2),
                        gradient: RadialGradient(
                          center: const Alignment(.12, .10),
                          colors: [
                            refractiveTint.withValues(alpha: .035),
                            const Color(0xFF8E8E93).withValues(alpha: .028),
                            Colors.transparent,
                          ],
                          stops: const [0, .50, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Padding(padding: padding ?? EdgeInsets.zero, child: child),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LiquidLensPainter(radius: borderRadius - 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      panel = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: panel,
      );
    }
    return panel;
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.size = 45,
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
        borderRadius: size * .38,
        blur: 25,
        opacity: selected ? .62 : .46,
        shadow: false,
        tint: AppColors.graphite,
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: size * .47,
            color: selected ? AppColors.accent : AppColors.graphite,
          ),
        ),
      ),
    );
    if (tooltip != null) result = Tooltip(message: tooltip!, child: result);
    return Opacity(opacity: onPressed == null ? .42 : 1, child: result);
  }
}

class _NeutralOrb extends StatelessWidget {
  const _NeutralOrb({
    required this.width,
    required this.height,
    required this.colors,
    required this.angle,
  });

  final double width;
  final double height;
  final List<Color> colors;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpticalVeil extends StatelessWidget {
  const _OpticalVeil();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _OpticalVeilPainter()));
  }
}

class _OpticalVeilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bright = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0xA8FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Offset.zero & size);

    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..shader = const LinearGradient(
        colors: [Color(0x00787880), Color(0x16787880), Color(0x00787880)],
      ).createShader(Offset.zero & size);

    final path1 = Path()
      ..moveTo(-50, size.height * .20)
      ..cubicTo(
        size.width * .22,
        size.height * .10,
        size.width * .62,
        size.height * .39,
        size.width + 50,
        size.height * .25,
      );
    final path2 = Path()
      ..moveTo(-55, size.height * .72)
      ..cubicTo(
        size.width * .28,
        size.height * .57,
        size.width * .62,
        size.height * .88,
        size.width + 52,
        size.height * .66,
      );
    canvas.drawPath(path1, bright);
    canvas.drawPath(path2, dark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LiquidLensPainter extends CustomPainter {
  const _LiquidLensPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(.65),
      Radius.circular(radius),
    );

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0x8FFFFFFF),
          Color(0x28FFFFFF),
          Color(0xA8FFFFFF),
        ],
        stops: [0, .34, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, rim);

    final innerRect = rect.deflate(2.3);
    if (innerRect.width <= 0 || innerRect.height <= 0) return;
    final inner = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular((radius - 2).clamp(0, radius).toDouble()),
    );
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xAFFFFFFF), Color(0x00FFFFFF), Color(0x17787880)],
        stops: [0, .58, 1],
      ).createShader(innerRect);
    canvas.drawRRect(inner, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidLensPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}
