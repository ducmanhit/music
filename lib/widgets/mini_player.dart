import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../screens/now_playing_screen.dart';
import 'song_artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
