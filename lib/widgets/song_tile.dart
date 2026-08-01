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
    this.selected = false,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onMore;
  final bool dense;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final selectedBackground = Theme.of(context).brightness == Brightness.dark
        ? context.tokens.surfaceMuted
        : context.tokens.accentSoft;
    return Material(
      color: selected ? selectedBackground : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: dense ? 8 : 10),
          child: Row(
            children: [
              SongArtwork(
                song: song,
                size: dense ? 48 : 56,
                borderRadius: dense ? 13 : 15,
                showBorder: false,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (song.isFavorite) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.favorite_rounded, size: 15, color: context.tokens.danger),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.artist} · ${song.extension.isEmpty ? 'AUDIO' : song.extension}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.tokens.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (song.durationMs > 0) ...[
                const SizedBox(width: 10),
                Text(
                  formatDuration(song.duration),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.tokens.textMuted,
                      ),
                ),
              ],
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  tooltip: 'Tùy chọn',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.more_horiz_rounded, color: context.tokens.textMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
