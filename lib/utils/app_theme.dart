import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF2F7FF);
  static const backgroundSoft = Color(0xFFE8F1FF);
  static const surface = Color(0x66FFFFFF);
  static const surfaceRaised = Color(0xA8FFFFFF);
  static const search = Color(0x52FFFFFF);
  static const line = Color(0x59FFFFFF);
  static const lineStrong = Color(0x8FFFFFFF);
  static const accent = Color(0xFF087CFF);
  static const accentBright = Color(0xFF55B8FF);
  static const accentDark = Color(0x21087CFF);
  static const cyan = Color(0xFF51D7E8);
  static const violet = Color(0xFF8878FF);
  static const pink = Color(0xFFFF8DC7);
  static const text = Color(0xFF10203A);
  static const muted = Color(0xFF60708B);
  static const mutedSoft = Color(0xFF93A0B5);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF30B66B);
  static const ink = Colors.white;
}

abstract final class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7FBFF),
      Color(0xFFEAF4FF),
      Color(0xFFF5EDFF),
      Color(0xFFEAFBFA),
    ],
    stops: [0, .38, .72, 1],
  );

  static const accentSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x9FFFFFFF),
      Color(0x3DF5FAFF),
      Color(0x26BCEAFF),
    ],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4AB8FF), Color(0xFF8178FF), Color(0xFFFF8DC7)],
  );

  static const glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF2FFFFFF),
      Color(0x70FFFFFF),
      Color(0x38A7CFFF),
      Color(0xA6FFFFFF),
    ],
    stops: [0, .34, .70, 1],
  );
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    primary: AppColors.accent,
    surface: Colors.white.withValues(alpha: .72),
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
      height: 65,
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.white.withValues(alpha: .42),
      elevation: 0,
      shadowColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.muted,
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
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.25),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.accent,
        disabledBackgroundColor: const Color(0xFFD5DCE7),
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
        backgroundColor: Colors.white.withValues(alpha: .28),
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
      iconColor: AppColors.muted,
      textColor: AppColors.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 14),
    ),
    dividerTheme: const DividerThemeData(color: Color(0x2A74829A), thickness: 1),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: Colors.white.withValues(alpha: .50),
      thumbColor: Colors.white,
      overlayColor: AppColors.accent.withValues(alpha: .12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withValues(alpha: .80),
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withValues(alpha: .88),
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xE81F2937),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withValues(alpha: .92),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      textStyle: const TextStyle(color: AppColors.text),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.accent,
      dividerColor: Color(0x2874829A),
      labelStyle: TextStyle(fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}

/// A vivid background is essential for believable liquid glass. The colored
/// shapes remain behind every translucent surface so blur and refraction are
/// visible instead of looking like plain white cards.
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
            top: -108,
            right: -92,
            child: _AuroraBlob(
              width: 310,
              height: 300,
              colors: [Color(0x8A49C7FF), Color(0x667B77FF)],
              angle: .35,
            ),
          ),
          const Positioned(
            left: -148,
            top: 250,
            child: _AuroraBlob(
              width: 330,
              height: 390,
              colors: [Color(0x74FF91C8), Color(0x595AAFFF)],
              angle: -.42,
            ),
          ),
          const Positioned(
            right: -130,
            bottom: 90,
            child: _AuroraBlob(
              width: 310,
              height: 350,
              colors: [Color(0x7053E3CF), Color(0x664CB6FF)],
              angle: .6,
            ),
          ),
          const Positioned(
            left: 72,
            bottom: -125,
            child: _AuroraBlob(
              width: 260,
              height: 260,
              colors: [Color(0x5DFFF0A8), Color(0x38FFFFFF)],
              angle: -.2,
            ),
          ),
          const Positioned.fill(child: _PrismaticVeil()),
          child,
        ],
      ),
    );
  }
}

/// A reusable liquid-glass surface. It combines strong backdrop blur, a low
/// opacity material tint, a prismatic inner glow and asymmetric lens highlights.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.blur = 30,
    this.opacity = .30,
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
    final effectiveTint = tint ?? AppColors.accent;

    Widget panel = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.glassBorder,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: const Color(0xFF29486F).withValues(alpha: .14),
                  blurRadius: 30,
                  spreadRadius: -8,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: .50),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(-5, -5),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(1.15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((borderRadius - 1.15).clamp(0, 999).toDouble()),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1.1, -1.15),
                      end: const Alignment(1.0, 1.05),
                      colors: [
                        Colors.white.withValues(alpha: opacity + .18),
                        Colors.white.withValues(alpha: opacity * .56),
                        effectiveTint.withValues(alpha: .075),
                        Colors.white.withValues(alpha: opacity * .78),
                      ],
                      stops: const [0, .34, .72, 1],
                    ),
                  ),
                ),
              ),
              if (highlight) ...[
                Positioned(
                  left: -borderRadius * .35,
                  top: -borderRadius * .72,
                  width: borderRadius * 4.1,
                  height: borderRadius * 2.35,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius * 2),
                        gradient: RadialGradient(
                          center: const Alignment(-.25, -.35),
                          radius: .82,
                          colors: [
                            Colors.white.withValues(alpha: .58),
                            Colors.white.withValues(alpha: .16),
                            Colors.transparent,
                          ],
                          stops: const [0, .46, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -borderRadius * .90,
                  bottom: -borderRadius * 1.22,
                  width: borderRadius * 4.5,
                  height: borderRadius * 3.15,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius * 2),
                        gradient: RadialGradient(
                          center: const Alignment(.15, .10),
                          colors: [
                            effectiveTint.withValues(alpha: .15),
                            effectiveTint.withValues(alpha: .05),
                            Colors.transparent,
                          ],
                          stops: const [0, .48, 1],
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
                    painter: _LiquidLensPainter(
                      radius: borderRadius - 1.2,
                      tint: effectiveTint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      panel = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: panel);
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
        borderRadius: size * .37,
        blur: 22,
        opacity: selected ? .34 : .20,
        shadow: false,
        tint: selected ? AppColors.accent : AppColors.cyan,
        onTap: onPressed,
        child: Center(
          child: Icon(
            icon,
            size: size * .48,
            color: selected ? AppColors.accent : AppColors.text,
          ),
        ),
      ),
    );
    if (tooltip != null) result = Tooltip(message: tooltip!, child: result);
    return Opacity(opacity: onPressed == null ? .45 : 1, child: result);
  }
}

class _AuroraBlob extends StatelessWidget {
  const _AuroraBlob({
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
        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
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

class _PrismaticVeil extends StatelessWidget {
  const _PrismaticVeil();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _PrismaticVeilPainter()),
    );
  }
}

class _PrismaticVeilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x38FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(-40, size.height * .22)
      ..cubicTo(
        size.width * .20,
        size.height * .12,
        size.width * .62,
        size.height * .42,
        size.width + 40,
        size.height * .26,
      )
      ..moveTo(-50, size.height * .70)
      ..cubicTo(
        size.width * .28,
        size.height * .58,
        size.width * .60,
        size.height * .88,
        size.width + 45,
        size.height * .68,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LiquidLensPainter extends CustomPainter {
  const _LiquidLensPainter({required this.radius, required this.tint});

  final double radius;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(.65), Radius.circular(radius));

    final topLens = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: .94),
          Colors.white.withValues(alpha: .22),
          tint.withValues(alpha: .10),
          Colors.white.withValues(alpha: .48),
        ],
        stops: const [0, .35, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, topLens);

    final innerRect = rect.deflate(2.2);
    if (innerRect.width <= 0 || innerRect.height <= 0) return;
    final inner = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular((radius - 2).clamp(0, radius).toDouble()),
    );
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: .52),
          Colors.transparent,
          tint.withValues(alpha: .13),
        ],
        stops: const [0, .58, 1],
      ).createShader(innerRect);
    canvas.drawRRect(inner, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidLensPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.tint != tint;
  }
}
