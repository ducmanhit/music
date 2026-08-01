import 'dart:io';

import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/app_theme.dart';

class SongArtwork extends StatelessWidget {
  const SongArtwork({
    super.key,
    required this.song,
    this.size = 54,
    this.borderRadius = 14,
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
    final image = ClipRRect(
      borderRadius: radius,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
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
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final letter = song.title.trim().isEmpty
        ? '♪'
        : song.title.trim().substring(0, 1).toUpperCase();
    return ColoredBox(
      color: context.tokens.surfaceHigh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 30,
            color: context.tokens.textTertiary.withValues(alpha: 0.55),
          ),
          Positioned(
            bottom: 7,
            right: 8,
            child: Text(
              letter,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
