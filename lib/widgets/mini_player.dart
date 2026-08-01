import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../screens/now_playing_screen.dart';
import 'song_artwork.dart';
import 'studio_widgets.dart';

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
      animation: Listenable.merge(<Listenable>[
        libraryService,
        playerController,
      ]),
      builder: (context, _) {
        final song = playerController.currentSong;
        if (song == null) return const SizedBox.shrink();

        final player = playerController.player;
        final duration = player.duration ?? song.duration;
        final maxMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
        final progress = (player.position.inMilliseconds / maxMs)
            .clamp(0.0, 1.0)
            .toDouble();

        return PressableScale(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NowPlayingScreen(
                libraryService: libraryService,
                playerController: playerController,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(26),
          child: Container(
            height: 74,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? context.tokens.accent : context.tokens.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: context.tokens.border),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  child: Row(
                    children: [
                      SongArtwork(
                        song: song,
                        size: 48,
                        borderRadius: 13,
                        showBorder: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText : null),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText.withValues(alpha: 0.62) : null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniControl(
                        size: 38,
                        icon: player.processingState == ProcessingState.loading ||
                                player.processingState ==
                                    ProcessingState.buffering
                            ? Icons.hourglass_top_rounded
                            : player.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                        onPressed: playerController.playOrPause,
                        filled: true,
                      ),
                      const SizedBox(width: 4),
                      _MiniControl(
                        size: 36,
                        icon: Icons.skip_next_rounded,
                        onPressed: playerController.next,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      value: progress,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText.withValues(alpha: 0.14) : context.tokens.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText : context.tokens.textPrimary,
                      ),
                    ),
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

class _MiniControl extends StatelessWidget {
  const _MiniControl({
    required this.size,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final double size;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: filled
              ? (Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText : context.tokens.accent)
              : Colors.transparent,
          foregroundColor: filled
              ? (Theme.of(context).brightness == Brightness.dark ? context.tokens.accent : context.tokens.accentText)
              : (Theme.of(context).brightness == Brightness.dark ? context.tokens.accentText : context.tokens.textPrimary),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon, size: filled ? 23 : 22),
      ),
    );
  }
}
