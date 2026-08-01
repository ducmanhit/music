import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class MiniPlayer extends StatelessWidget {
  final dynamic playerController;
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.playerController,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentSong = playerController.currentSong;

    if (currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                color: AppColors.secondarySurface,
                child: currentSong.artworkUrl != null
                    ? Image.network(currentSong.artworkUrl, fit: BoxFit.cover)
                    : const Icon(Icons.music_note_rounded, color: AppColors.textMuted, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong.title ?? 'Unsayable',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.artist ?? 'Brambles',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textSecondary, size: 20),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: playerController.togglePlay,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playerController.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
