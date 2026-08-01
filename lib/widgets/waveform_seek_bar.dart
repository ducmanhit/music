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
    this.waveHeight = 48,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final double waveHeight;

  @override
  Widget build(BuildContext context) {
    final maximum = math.max(1, duration.inMilliseconds).toDouble();
    final value = position.inMilliseconds.clamp(0, maximum.toInt()).toDouble();
    return Column(
      children: [
        Slider(
          min: 0,
          max: maximum,
          value: value,
          onChanged: (next) => onSeek(Duration(milliseconds: next.round())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
              Text(
                formatDuration(duration),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
