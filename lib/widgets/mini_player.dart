import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../utils/app_theme.dart';
=======
import 'package:just_audio/just_audio.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../screens/now_playing_screen.dart';
import 'song_artwork.dart';
>>>>>>> f2ae42124e3a6e35c7f29ddeb1ab7ecd5b62ba21

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
<<<<<<< HEAD
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
=======
    return AnimatedBuilder(
      animation: playerController,
      builder: (context, _) {
        final song = playerController.currentSong;
        if (song == null) return const SizedBox.shrink();
        final player = playerController.player;
        final duration = player.duration ?? song.duration;
        final position = player.position;
        final progress = duration.inMilliseconds <= 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
                .toDouble();

        return Material(
          color: context.tokens.surface,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NowPlayingScreen(
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  minHeight: 2,
                  value: progress,
                  backgroundColor: context.tokens.surfaceStrong,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                  child: Row(
                    children: [
                      SongArtwork(song: song, size: 48, borderRadius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: playerController.previous,
                        tooltip: 'Bài trước',
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      IconButton.filled(
                        onPressed: playerController.playOrPause,
                        tooltip: player.playing ? 'Tạm dừng' : 'Phát',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(42, 42),
                        ),
                        icon: Icon(
                          player.playing
                              ? Icons.pause_rounded
                              : player.processingState == ProcessingState.loading ||
                                      player.processingState == ProcessingState.buffering
                                  ? Icons.hourglass_top_rounded
                                  : Icons.play_arrow_rounded,
                        ),
                      ),
                      IconButton(
                        onPressed: playerController.next,
                        tooltip: 'Bài tiếp theo',
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
>>>>>>> f2ae42124e3a6e35c7f29ddeb1ab7ecd5b62ba21
    );
  }
}
