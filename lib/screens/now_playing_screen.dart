import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_modal.dart';
import '../widgets/song_artwork.dart';
import '../widgets/studio_widgets.dart';
import '../widgets/waveform_seek_bar.dart';
import 'cover_editor_screen.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
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
        if (song == null) {
          return Scaffold(
            backgroundColor: context.tokens.background,
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.music_off_rounded,
              title: 'Chưa có bài hát đang phát',
              message: 'Chọn một bài trong thư viện để bắt đầu.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.tokens.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 690;
                final veryCompact = constraints.maxHeight < 610;
                final horizontal = constraints.maxWidth < 390 ? 20.0 : 24.0;
                final controlsSize = compact ? 64.0 : 72.0;
                final maxArtwork = math
                    .min(
                      constraints.maxWidth - horizontal * 2,
                      constraints.maxHeight *
                          (veryCompact ? 0.29 : compact ? 0.34 : 0.42),
                    )
                    .toDouble();
                final artworkSize = math.min(maxArtwork, 360.0).toDouble();

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    children: [
                      _TopBar(
                        onClose: () => Navigator.pop(context),
                        onQueue: () => _showQueue(context),
                      ),
                      SizedBox(height: veryCompact ? 4 : 10),
                      Expanded(
                        child: Center(
                          child: SizedBox.square(
                            dimension: artworkSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: SongArtwork(
                                song: song,
                                size: artworkSize,
                                borderRadius: 28,
                                showBorder: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: veryCompact ? 8 : compact ? 12 : 18),
                      _TrackInfo(
                        song: song,
                        libraryService: libraryService,
                      ),
                      SizedBox(height: veryCompact ? 6 : 10),
                      WaveformSeekBar(
                        position: playerController.player.position,
                        duration: playerController.player.duration ?? song.duration,
                        onSeek: playerController.seek,
                      ),
                      SizedBox(height: veryCompact ? 4 : 8),
                      _TransportControls(
                        playerController: playerController,
                        playButtonSize: controlsSize,
                      ),
                      SizedBox(height: veryCompact ? 4 : 8),
                      _SecondaryActions(
                        onQueue: () => _showQueue(context),
                        onLyrics: () => _showLyrics(context, song),
                        onDevice: () => _showDeviceInfo(context),
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CoverEditorScreen(
                              songId: song.id,
                              libraryService: libraryService,
                              playerController: playerController,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: veryCompact ? 4 : 10),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQueue(BuildContext context) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            title: 'Danh sách chờ',
            subtitle: '${playerController.queue.length} bài hát',
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(sheetContext).bottom + 12,
              ),
              itemCount: playerController.queue.length,
              separatorBuilder: (_, __) => const AppSheetDivider(indent: 20),
              itemBuilder: (context, index) {
                final song = playerController.queue[index];
                final active = index == playerController.currentIndex;
                return ListTile(
                  selected: active,
                  selectedTileColor: context.tokens.surfaceHigh,
                  leading: SongArtwork(
                    song: song,
                    size: 46,
                    borderRadius: 13,
                    showBorder: false,
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: active
                      ? const Icon(Icons.graphic_eq_rounded)
                      : Text(formatDuration(song.duration)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await playerController.playSong(playerController.queue, song);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLyrics(BuildContext context, Song song) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(title: 'Lời bài hát', subtitle: song.title),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.paddingOf(sheetContext).bottom + 24,
              ),
              child: Text(
                song.lyrics?.trim().isNotEmpty == true
                    ? song.lyrics!
                    : 'File nhạc này không có lời bài hát trong metadata.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeviceInfo(BuildContext context) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(
            title: 'Thiết bị phát',
            subtitle:
                'Chọn AirPlay hoặc Bluetooth trong Control Center của iPhone.',
          ),
          AppSheetAction(
            icon: Icons.airplay_rounded,
            title: 'Mở Control Center',
            subtitle: 'Vuốt từ góc trên bên phải của màn hình',
            trailing: const SizedBox.shrink(),
            onTap: () => Navigator.pop(sheetContext),
          ),
          SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom + 12),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onQueue});

  final VoidCallback onClose;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            tooltip: 'Thu nhỏ',
            onPressed: onClose,
            size: 40,
          ),
          Expanded(
            child: Text(
              'ĐANG PHÁT',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.1,
                  ),
            ),
          ),
          CircleIconButton(
            icon: Icons.queue_music_rounded,
            tooltip: 'Danh sách chờ',
            onPressed: onQueue,
            size: 40,
          ),
        ],
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.song, required this.libraryService});

  final Song song;
  final LibraryService libraryService;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 42),
        Expanded(
          child: Column(
            children: [
              Text(
                song.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),
              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.tokens.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 42,
          child: IconButton(
            onPressed: () => libraryService.toggleFavorite(song.id),
            icon: Icon(
              song.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: song.isFavorite
                  ? context.tokens.danger
                  : context.tokens.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.playerController,
    required this.playButtonSize,
  });

  final PlayerController playerController;
  final double playButtonSize;

  @override
  Widget build(BuildContext context) {
    final player = playerController.player;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ToggleButton(
          icon: Icons.shuffle_rounded,
          selected: playerController.shuffleEnabled,
          onPressed: playerController.toggleShuffle,
        ),
        _TransportButton(
          icon: Icons.skip_previous_rounded,
          onPressed: playerController.previous,
        ),
        SizedBox.square(
          dimension: playButtonSize,
          child: FilledButton(
            onPressed: playerController.playOrPause,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Icon(
              player.processingState == ProcessingState.loading ||
                      player.processingState == ProcessingState.buffering
                  ? Icons.hourglass_top_rounded
                  : player.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              size: playButtonSize * 0.53,
            ),
          ),
        ),
        _TransportButton(
          icon: Icons.skip_next_rounded,
          onPressed: playerController.next,
        ),
        _ToggleButton(
          icon: playerController.loopMode == LoopMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          selected: playerController.loopMode != LoopMode.off,
          onPressed: playerController.cycleLoopMode,
        ),
      ],
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 31),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor:
              selected ? context.tokens.surfaceHigh : Colors.transparent,
        ),
        icon: Icon(
          icon,
          size: 22,
          color: selected
              ? context.tokens.textPrimary
              : context.tokens.textTertiary,
        ),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({
    required this.onQueue,
    required this.onLyrics,
    required this.onDevice,
    required this.onEdit,
  });

  final VoidCallback onQueue;
  final VoidCallback onLyrics;
  final VoidCallback onDevice;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.queue_music_rounded, label: 'Hàng chờ', onTap: onQueue),
      (icon: Icons.lyrics_outlined, label: 'Lời bài hát', onTap: onLyrics),
      (icon: Icons.airplay_rounded, label: 'Thiết bị', onTap: onDevice),
      (icon: Icons.edit_outlined, label: 'Chỉnh sửa', onTap: onEdit),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (final action in actions)
          Expanded(
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action.icon,
                      size: 20,
                      color: context.tokens.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
