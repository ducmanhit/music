import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class WaveformSeekBar extends StatelessWidget {
  const WaveformSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.waveHeight = 86,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final double waveHeight;

  @override
  Widget build(BuildContext context) {
    final max = math.max(1, duration.inMilliseconds).toDouble();
    final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
    return Column(
      children: [
        SizedBox(
          height: waveHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePainter(progress: value / max),
                ),
              ),
              Positioned.fill(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.transparent,
                    overlayColor: const Color(0x225BE0CF),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    min: 0,
                    max: max,
                    value: value,
                    onChanged: (next) =>
                        onSeek(Duration(milliseconds: next.round())),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDuration(position), style: const TextStyle(color: AppColors.muted)),
            Text(formatDuration(duration), style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 44;
    const gap = 4.0;
    final width = (size.width - gap * (count - 1)) / count;
    final played = Paint()
      ..color = AppColors.accent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width.clamp(2.0, 5.0);
    final unplayed = Paint()
      ..color = const Color(0xFF3B444C)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width.clamp(2.0, 5.0);

    for (var i = 0; i < count; i++) {
      final x = i * (width + gap) + width / 2;
      final normalized = i / (count - 1);
      final wave = .24 +
          .55 * (math.sin(i * .87).abs()) +
          .15 * (math.sin(i * .29 + 1.7).abs());
      final barHeight = (size.height * wave).clamp(14.0, size.height - 5);
      final y1 = (size.height - barHeight) / 2;
      final y2 = y1 + barHeight;
      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        normalized <= progress ? played : unplayed,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
