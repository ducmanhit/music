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
                  final compact = constraints.maxHeight < 700;
                  final horizontal = constraints.maxWidth > 620 ? 42.0 : 20.0;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 6, horizontal, 14),
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
                        SizedBox(height: compact ? 4 : 12),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430, maxHeight: 430),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: SongArtwork(
                                  song: song,
                                  size: 430,
                                  borderRadius: compact ? 20 : 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 18),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: _PlayerPanel(
                            song: song,
                            compact: compact,
                            libraryService: libraryService,
                            playerController: playerController,
                          ),
                        ),
                      ],
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
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(onPressed: onClose, icon: const Icon(Icons.keyboard_arrow_down_rounded)),
          const Expanded(
            child: Text(
              'ĐANG PHÁT',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
          ),
          IconButton(onPressed: onEdit, tooltip: 'Sửa thông tin', icon: const Icon(Icons.edit_outlined)),
        ],
      ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
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
            IconButton(
              onPressed: () => libraryService.toggleFavorite(song.id),
              tooltip: song.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
              icon: Icon(
                song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: song.isFavorite ? context.tokens.danger : null,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 4 : 10),
        WaveformSeekBar(
          position: position,
          duration: duration,
          onSeek: playerController.seek,
        ),
        SizedBox(height: compact ? 4 : 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ToggleButton(
              icon: Icons.shuffle_rounded,
              selected: playerController.shuffleEnabled,
              tooltip: 'Phát ngẫu nhiên',
              onPressed: playerController.toggleShuffle,
            ),
            IconButton(
              onPressed: playerController.previous,
              tooltip: 'Bài trước',
              iconSize: compact ? 36 : 40,
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            SizedBox.square(
              dimension: compact ? 66 : 74,
              child: IconButton.filled(
                onPressed: playerController.playOrPause,
                tooltip: player.playing ? 'Tạm dừng' : 'Phát',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                iconSize: compact ? 38 : 44,
                icon: Icon(
                  player.processingState == ProcessingState.loading ||
                          player.processingState == ProcessingState.buffering
                      ? Icons.hourglass_top_rounded
                      : player.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                ),
              ),
            ),
            IconButton(
              onPressed: playerController.next,
              tooltip: 'Bài tiếp theo',
              iconSize: compact ? 36 : 40,
              icon: const Icon(Icons.skip_next_rounded),
            ),
            _ToggleButton(
              icon: playerController.loopMode == LoopMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              selected: playerController.loopMode != LoopMode.off,
              tooltip: 'Chế độ lặp',
              onPressed: playerController.cycleLoopMode,
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 12),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                      ? Icon(Icons.graphic_eq_rounded, color: Theme.of(context).colorScheme.primary)
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

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: selected ? context.tokens.accentSoft : Colors.transparent,
        foregroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : context.tokens.textMuted,
      ),
      icon: Icon(icon),
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
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: context.tokens.textMuted),
            const SizedBox(height: 5),
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
