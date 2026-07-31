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
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
          child: GlassPanel(
            borderRadius: 23,
            blur: 34,
            opacity: .12,
            tint: AppColors.cyan,
            shadow: false,
            onTap: () => _openNowPlaying(context),
            child: SizedBox(
              height: 67,
              child: Stack(
                children: [
                  Positioned(
                    left: 11,
                    right: 11,
                    bottom: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2.5,
                        backgroundColor: Colors.white.withValues(alpha: .38),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 8, 7, 9),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'now-playing-art-${song.id}',
                          child: SongArtwork(
                            song: song,
                            size: 48,
                            borderRadius: 15,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  song.title,
                                  key: ValueKey(song.id),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _LiquidControlButton(
                          tooltip: playerController.player.playing
                              ? 'Tạm dừng'
                              : 'Phát',
                          primary: true,
                          onPressed: playerController.playOrPause,
                          icon: playerController.player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        const SizedBox(width: 4),
                        _LiquidControlButton(
                          tooltip: 'Bài tiếp theo',
                          onPressed: playerController.next,
                          icon: Icons.skip_next_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNowPlaying(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, secondaryAnimation) => NowPlayingScreen(
          libraryService: libraryService,
          playerController: playerController,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _LiquidControlButton extends StatelessWidget {
  const _LiquidControlButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.primary = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: primary ? 42 : 38,
        child: GlassPanel(
          borderRadius: primary ? 15 : 14,
          blur: 18,
          opacity: primary ? .34 : .10,
          tint: primary ? AppColors.accent : AppColors.cyan,
          shadow: false,
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: primary ? 25 : 23,
              color: primary ? AppColors.accent : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
