import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SongTile extends StatelessWidget {
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
