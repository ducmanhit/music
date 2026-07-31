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
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GlassPanel(
            borderRadius: 25,
            blur: 32,
            opacity: .56,
            tint: AppColors.graphite,
            shadow: true,
            onTap: () => _openNowPlaying(context),
            child: SizedBox(
              height: 69,
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
                        backgroundColor: const Color(0x23787880),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.graphite,
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
        child: primary
            ? GestureDetector(
                onTap: onPressed,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.graphite.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withValues(alpha: .72)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .16),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, size: 25, color: Colors.white),
                  ),
                ),
              )
            : GlassPanel(
                borderRadius: 14,
                blur: 18,
                opacity: .50,
                tint: AppColors.graphite,
                shadow: false,
                onTap: onPressed,
                child: Center(
                  child: Icon(icon, size: 23, color: AppColors.graphite),
                ),
              ),
      ),
    );
  }
}
