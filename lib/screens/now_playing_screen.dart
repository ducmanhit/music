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
      animation: Listenable.merge(<Listenable>[libraryService, playerController]),
      builder: (context, _) {
        final song = playerController.currentSong;
        if (song == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.music_off_rounded,
              title: 'Chưa có bài hát đang phát',
              message: 'Chọn một bài hát trong thư viện để bắt đầu.',
            ),
          );
        }
        return Scaffold(
          body: ColoredBox(
            color: context.tokens.canvas,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, compact ? 20 : 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            _TopBar(
                              onClose: () => Navigator.maybePop(context),
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
                            SizedBox(height: compact ? 12 : 22),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.tokens.surfaceMuted,
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(color: context.tokens.border),
                              ),
                              child: SongArtwork(
                                song: song,
                                size: 360,
                                borderRadius: 30,
                                showBorder: false,
                              ),
                            ),
                            SizedBox(height: compact ? 18 : 24),
                            _PlayerPanel(
                              song: song,
                              compact: compact,
                              libraryService: libraryService,
                              playerController: playerController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onEdit});

  final VoidCallback onClose;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FlatIconButton(
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: 'Đóng',
          onPressed: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text(
                'NOW PLAYING',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      color: context.tokens.textFaint,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phát từ thư viện offline',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.tokens.textMuted,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FlatIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Sửa thông tin',
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.song,
    required this.compact,
    required this.libraryService,
    required this.playerController,
  });

  final Song song;
  final bool compact;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final player = playerController.player;
    final duration = player.duration ?? song.duration;
    final position = player.position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.tokens.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FlatIconButton(
              icon: song.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              selected: song.isFavorite,
              danger: song.isFavorite,
              tooltip: song.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
              onPressed: () => libraryService.toggleFavorite(song.id),
            ),
          ],
        ),
        SizedBox(height: compact ? 14 : 18),
        SurfaceCard(
          radius: 28,
          color: context.tokens.surface,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            children: [
              WaveformSeekBar(
                position: position,
                duration: duration,
                onSeek: playerController.seek,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundToggle(
                    icon: Icons.shuffle_rounded,
                    selected: playerController.shuffleEnabled,
                    onPressed: playerController.toggleShuffle,
                  ),
                  _RoundTransport(
                    icon: Icons.skip_previous_rounded,
                    onPressed: playerController.previous,
                  ),
                  FilledButton(
                    onPressed: playerController.playOrPause,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(compact ? 72 : 82, compact ? 72 : 82),
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
                      size: compact ? 38 : 44,
                    ),
                  ),
                  _RoundTransport(
                    icon: Icons.skip_next_rounded,
                    onPressed: playerController.next,
                  ),
                  _RoundToggle(
                    icon: playerController.loopMode == LoopMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    selected: playerController.loopMode != LoopMode.off,
                    onPressed: playerController.cycleLoopMode,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        SurfaceCard(
          radius: 26,
          color: context.tokens.surfaceMuted,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _PanelAction(
                  icon: Icons.queue_music_rounded,
                  label: 'Danh sách',
                  onTap: () => _showQueue(context),
                ),
              ),
              Expanded(
                child: _PanelAction(
                  icon: Icons.lyrics_outlined,
                  label: 'Lời bài hát',
                  onTap: () => _showLyrics(context),
                ),
              ),
              Expanded(
                child: _PanelAction(
                  icon: Icons.timer_outlined,
                  label: 'Hẹn giờ',
                  onTap: () => _showSleepTimer(context),
                ),
              ),
              Expanded(
                child: _PanelAction(
                  icon: Icons.info_outline_rounded,
                  label: 'Thông tin',
                  onTap: () => _showInfo(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showQueue(BuildContext context) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            title: 'Danh sách phát',
            subtitle: '${playerController.queue.length} bài hát',
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .58),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: playerController.queue.length,
              itemBuilder: (context, index) {
                final item = playerController.queue[index];
                final current = playerController.currentIndex == index;
                return ListTile(
                  selected: current,
                  leading: SongArtwork(song: item, size: 46, borderRadius: 11),
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(item.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: current
                      ? const Icon(Icons.graphic_eq_rounded, color: Colors.white)
                      : Text('${index + 1}', style: TextStyle(color: context.tokens.textMuted)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    playerController.playSong(playerController.queue, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLyrics(BuildContext context) async {
    final lyrics = song.lyrics?.trim();
    await showAppSheet<void>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(title: 'Lời bài hát'),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .58),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Text(
                lyrics == null || lyrics.isEmpty
                    ? 'File nhạc này chưa có lời bài hát được nhúng.'
                    : lyrics,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context) async {
    final selected = await showAppSelectionSheet<String>(
      context: context,
      title: 'Hẹn giờ tắt nhạc',
      options: const [
        AppSelectionOption(value: '10', title: '10 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: '20', title: '20 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: '30', title: '30 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: '45', title: '45 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: '60', title: '60 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 'off', title: 'Tắt hẹn giờ', icon: Icons.timer_off_outlined),
      ],
    );
    if (!context.mounted || selected == null) return;
    if (selected == 'off') {
      playerController.setSleepTimer(null);
    } else {
      playerController.setSleepTimer(Duration(minutes: int.parse(selected)));
    }
  }

  Future<void> _showInfo(BuildContext context) async {
    await showAppSheet<void>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(title: 'Thông tin âm thanh'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SurfaceCard(
              radius: 22,
              child: Column(
                children: [
                  _InfoRow(label: 'Định dạng', value: song.extension.isEmpty ? 'Không rõ' : song.extension),
                  const Divider(),
                  _InfoRow(label: 'Thời lượng', value: formatDuration(song.duration)),
                  const Divider(),
                  _InfoRow(label: 'Bitrate', value: song.bitrateKbps == null ? 'Không rõ' : '${song.bitrateKbps} kbps'),
                  const Divider(),
                  _InfoRow(label: 'Sample rate', value: song.sampleRate == null ? 'Không rõ' : '${song.sampleRate} Hz'),
                  const Divider(),
                  _InfoRow(label: 'Album', value: song.album),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundToggle extends StatelessWidget {
  const _RoundToggle({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.tokens.surfaceStrong : context.tokens.surfaceMuted,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: selected ? Colors.white : context.tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

class _RoundTransport extends StatelessWidget {
  const _RoundTransport({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tokens.surfaceMuted,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 28),
        ),
      ),
    );
  }
}

class _PanelAction extends StatelessWidget {
  const _PanelAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: context.tokens.textMuted),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: context.tokens.textMuted)),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
