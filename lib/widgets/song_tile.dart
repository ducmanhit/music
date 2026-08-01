import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'song_artwork.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMore,
    this.dense = false,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onMore;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: dense ? 7 : 9),
          child: Row(
            children: [
              SongArtwork(
                song: song,
                size: dense ? 48 : 56,
                borderRadius: dense ? 12 : 14,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: dense ? 15 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.artist} • ${song.extension.isEmpty ? 'AUDIO' : song.extension}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (song.durationMs > 0)
                Text(
                  formatDuration(song.duration),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
