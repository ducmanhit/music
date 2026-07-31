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
    final hue = (seed % 360).toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, .58, .32).toColor(),
            HSLColor.fromAHSL(1, (hue + 58) % 360, .62, .12).toColor(),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -22,
            right: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
              ),
            ),
          ),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: .18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppColors.text,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
