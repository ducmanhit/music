import 'package:flutter/cupertino.dart';
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
        final queued = playerController.currentSong;
        if (queued == null) return const SizedBox.shrink();
        final song = libraryService.songById(queued.id) ?? queued;
        final duration = playerController.player.duration ?? song.duration;
        final position = playerController.player.position;
        final progress = duration.inMilliseconds <= 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GlassPanel(
            borderRadius: 27,
            blur: 26,
            opacity: .58,
            shadow: true,
            onTap: () => _openNowPlaying(context),
            child: SizedBox(
              height: 67,
              child: Stack(
                children: [
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2,
                        backgroundColor: const Color(0x1F3C3C43),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.graphite,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 8, 8, 8),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'now-playing-art-${song.id}',
                          child: SongArtwork(
                            song: song,
                            size: 49,
                            borderRadius: 14,
                          ),
                        ),
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
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.25,
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
                        _MiniButton(
                          onPressed: playerController.playOrPause,
                          icon: playerController.player.playing
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                          primary: true,
                        ),
                        const SizedBox(width: 5),
                        _MiniButton(
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
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 280),
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

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.onPressed,
    required this.icon,
    this.primary = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: primary ? 41 : 36,
        height: primary ? 41 : 36,
        decoration: BoxDecoration(
          color: primary
              ? AppColors.graphite
              : Colors.white.withValues(alpha: .50),
          borderRadius: BorderRadius.circular(primary ? 20.5 : 18),
          border: Border.all(
            color: Colors.white.withValues(alpha: primary ? .30 : .76),
          ),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: primary ? 20 : 18,
          color: primary ? Colors.white : AppColors.graphite,
        ),
      ),
    );
  }
}
