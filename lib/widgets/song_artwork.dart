import 'dart:io';

import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/app_theme.dart';

class SongArtwork extends StatelessWidget {
  const SongArtwork({
    super.key,
    required this.song,
    this.size = 54,
    this.borderRadius = 12,
    this.showBorder = true,
  });

  final Song song;
  final double size;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final path = song.artworkPath;
    final file = path == null ? null : File(path);
    final radius = BorderRadius.circular(borderRadius);
    final child = ClipRRect(
      borderRadius: radius,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: file != null && file.existsSync()
            ? Image.file(
                file,
                key: ValueKey<String>('art:${song.id}:$path'),
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => _Placeholder(
                  key: ValueKey<String>('placeholder:${song.id}'),
                  song: song,
                ),
              )
            : _Placeholder(
                key: ValueKey<String>('placeholder:${song.id}'),
                song: song,
              ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: showBorder ? Border.all(color: context.tokens.border) : null,
      ),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final seed = song.title.codeUnits.fold<int>(0, (sum, value) => sum + value);
    final colors = context.isDarkMode
        ? const <Color>[
            Color(0xFF253044),
            Color(0xFF2C2A3B),
            Color(0xFF203631),
            Color(0xFF3A2C2A),
            Color(0xFF2B3035),
          ]
        : const <Color>[
            Color(0xFFDDE7FA),
            Color(0xFFE8E2F1),
            Color(0xFFDDECE7),
            Color(0xFFF0E2DC),
            Color(0xFFE3E7EB),
          ];
    final background = colors[seed % colors.length];
    final letter = song.title.trim().isEmpty
        ? '♪'
        : song.title.trim().substring(0, 1).toUpperCase();
    return ColoredBox(
      color: background,
      child: Center(
        child: Text(
          letter,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
