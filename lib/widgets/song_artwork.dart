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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: artwork != null && File(artwork).existsSync()
            ? Image.file(
                File(artwork),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _Placeholder(song: song),
              )
            : _Placeholder(song: song),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.song});

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
            HSLColor.fromAHSL(1, hue, .48, .28).toColor(),
            HSLColor.fromAHSL(1, (hue + 55) % 360, .58, .12).toColor(),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: AppColors.text, size: 30),
      ),
    );
  }
}
