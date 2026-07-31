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
  });

  final Song song;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final artwork = song.artworkPath;
    final artworkFile = artwork == null ? null : File(artwork);
    final artworkKey = '${song.id}:${artwork ?? 'placeholder'}';

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: artworkFile != null && artworkFile.existsSync()
              ? Image.file(
                  artworkFile,
                  key: ValueKey<String>(artworkKey),
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
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final seed = song.title.codeUnits.fold<int>(0, (sum, value) => sum + value);
    const tones = <Color>[
      Color(0xFFE8ECF3),
      Color(0xFFF0ECE8),
      Color(0xFFE9F0ED),
      Color(0xFFEEEAF2),
      Color(0xFFECEEF1),
    ];
    final tone = tones[seed % tones.length];

    return ColoredBox(
      color: tone,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -18,
            right: -14,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .58),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .52),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .86),
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.graphiteSoft,
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
