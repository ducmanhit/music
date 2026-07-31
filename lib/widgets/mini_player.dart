import 'package:flutter/material.dart';

import '../screens/now_playing_screen.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
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
      animation: Listenable.merge([libraryService, playerController]),
      builder: (context, _) {
        final queueSong = playerController.currentSong;
        if (queueSong == null) return const SizedBox.shrink();
        final song = libraryService.songById(queueSong.id) ?? queueSong;
        final duration = playerController.player.duration ?? song.duration;
        final position = playerController.player.position;
        final progress = duration.inMilliseconds <= 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NowPlayingScreen(
                    libraryService: libraryService,
                    playerController: playerController,
                  ),
                ),
              ),
              child: Ink(
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppGradients.accentSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 9, 7, 11),
                      child: Row(
                        children: [
                          SongArtwork(song: song, size: 50, borderRadius: 13),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Bài trước',
                            visualDensity: VisualDensity.compact,
                            onPressed: playerController.previous,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: playerController.player.playing
                                  ? 'Tạm dừng'
                                  : 'Phát',
                              visualDensity: VisualDensity.compact,
                              onPressed: playerController.playOrPause,
                              color: AppColors.ink,
                              icon: Icon(
                                playerController.player.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Bài tiếp theo',
                            visualDensity: VisualDensity.compact,
                            onPressed: playerController.next,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
