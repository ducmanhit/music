import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SongTile extends StatelessWidget {
<<<<<<< HEAD
  final String indexString; 
  final String title;
  final String artist;
  final String duration;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    Key? key,
    required this.indexString,
    required this.title,
    required this.artist,
    required this.duration,
    this.isPlaying = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.activeHighlight : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: SizedBox(
          width: 32,
          child: isPlaying
              ? const Icon(Icons.equalizer_rounded, color: AppColors.textPrimary, size: 20)
              : Text(
                  indexString,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isPlaying ? AppColors.primary : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
=======
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
    final primary = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(15);
    return Material(
      color: selected ? context.tokens.accentSoft : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: dense ? 7 : 9),
          child: Row(
            children: [
              SongArtwork(
                song: song,
                size: dense ? 46 : 54,
                borderRadius: dense ? 11 : 13,
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: selected ? primary : null,
                            ),
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
>>>>>>> f2ae42124e3a6e35c7f29ddeb1ab7ecd5b62ba21
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$artist  •  $duration',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted, size: 20),
          onPressed: () {},
        ),
      ),
    );
  }
}
