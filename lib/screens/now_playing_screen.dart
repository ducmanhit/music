import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([libraryService, playerController]),
            builder: (context, _) {
              final queuedSong = playerController.currentSong;
              if (queuedSong == null) {
                return const Center(child: Text('Chưa có bài đang phát'));
              }
              final song = libraryService.songById(queuedSong.id) ?? queuedSong;
              final duration = playerController.player.duration ?? song.duration;
              final position = playerController.player.position;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  final deckHeight = compact ? 302.0 : 352.0;
                  final artworkArea = math.max(
                    150.0,
                    constraints.maxHeight - deckHeight - 58,
                  ).toDouble();
                  final artworkSize = math.min(
                    constraints.maxWidth - (compact ? 70 : 54),
                    artworkArea - 12,
                  ).clamp(150.0, 390.0).toDouble();

                  return Column(
                    children: [
                      _TopBar(
                        onClose: () => Navigator.pop(context),
                        onEdit: () => _openEditor(context, song),
                        onLyrics: () => _showLyrics(context, song),
                        onQuality: () => _showQuality(context, song),
                        onQueue: () => _showQueue(context),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            width: artworkSize + 18,
                            height: artworkSize + 18,
                            child: GlassPanel(
                              borderRadius: 36,
                              blur: 26,
                              opacity: .46,
                              tint: AppColors.graphite,
                              padding: const EdgeInsets.all(9),
                              child: Hero(
                                tag: 'now-playing-art-${song.id}',
                                child: SongArtwork(
                                  song: song,
                                  size: artworkSize,
                                  borderRadius: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          compact ? 3 : 8,
                          12,
                          8,
                        ),
                        child: SizedBox(
                          height: deckHeight,
                          child: GlassPanel(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 16 : 20,
                              compact ? 13 : 17,
                              compact ? 16 : 20,
                              compact ? 10 : 14,
                            ),
                            borderRadius: 32,
                            blur: 38,
                            opacity: .58,
                            tint: AppColors.graphite,
                            child: Column(
                              children: [
                                Text(
                                  song.title,
                                  maxLines: compact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: compact ? 20 : 23,
                                    height: 1.12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.5,
                                  ),
                                ),
                                SizedBox(height: compact ? 3 : 5),
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: compact ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: compact ? 7 : 10),
                                _MetadataLine(
                                  song: song,
                                  currentIndex: playerController.currentIndex,
                                  queueLength: playerController.queue.length,
                                  compact: compact,
                                ),
                                SizedBox(height: compact ? 5 : 9),
                                WaveformSeekBar(
                                  position: position,
                                  duration: duration,
                                  onSeek: playerController.seek,
                                  waveHeight: compact ? 51 : 65,
                                ),
                                SizedBox(height: compact ? 2 : 7),
                                _PlaybackControls(
                                  playerController: playerController,
                                  compact: compact,
                                ),
                                const Spacer(),
                                _BottomTools(
                                  song: song,
                                  libraryService: libraryService,
                                  playerController: playerController,
                                  onSleepTimer: () => _showSleepTimer(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, Song song) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoverEditorScreen(
          songId: song.id,
          libraryService: libraryService,
          playerController: playerController,
        ),
      ),
    );
  }

  Future<void> _showQueue(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        minChildSize: .4,
        maxChildSize: .94,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lineStrong,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Danh sách chờ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                itemCount: playerController.queue.length,
                itemBuilder: (context, index) {
                  final song = playerController.queue[index];
                  final selected = index == playerController.currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withValues(alpha: .1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: SongTile(
                        song: song,
                        dense: true,
                        onTap: () async {
                          await playerController.player.seek(
                            Duration.zero,
                            index: index,
                          );
                          await playerController.player.play();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLyrics(BuildContext context, Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        maxChildSize: .95,
        builder: (context, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lời bài hát',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              Text(song.title, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    song.lyrics?.trim().isNotEmpty == true
                        ? song.lyrics!
                        : 'File nhạc này không có lời bài hát trong metadata.',
                    style: const TextStyle(fontSize: 18, height: 1.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuality(BuildContext context, Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin âm thanh',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _QualityRow(
              label: 'Định dạng',
              value: song.extension.isEmpty ? 'Không rõ' : song.extension,
            ),
            _QualityRow(
              label: 'Bitrate',
              value: song.bitrateKbps == null
                  ? 'Không rõ'
                  : '${song.bitrateKbps} kbps',
            ),
            _QualityRow(
              label: 'Sample rate',
              value: song.sampleRate == null
                  ? 'Không rõ'
                  : '${(song.sampleRate! / 1000).toStringAsFixed(1)} kHz',
            ),
            _QualityRow(label: 'Dung lượng', value: formatBytes(song.fileSize)),
          ],
        ),
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context) async {
    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Hẹn giờ tắt nhạc',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              for (final minutes in [10, 20, 30, 45, 60, 90])
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('$minutes phút'),
                  onTap: () =>
                      Navigator.pop(context, Duration(minutes: minutes)),
                ),
              ListTile(
                leading: const Icon(Icons.timer_off_outlined),
                title: const Text('Tắt hẹn giờ'),
                onTap: () => Navigator.pop(context, Duration.zero),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    playerController.setSleepTimer(
      selected == Duration.zero ? null : selected,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onClose,
    required this.onEdit,
    required this.onLyrics,
    required this.onQuality,
    required this.onQueue,
  });

  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onLyrics;
  final VoidCallback onQuality;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GlassIconButton(
              icon: Icons.keyboard_arrow_down_rounded,
              tooltip: 'Đóng',
              onPressed: onClose,
            ),
            const Spacer(),
            GlassIconButton(
              icon: Icons.graphic_eq_rounded,
              tooltip: 'Thông tin âm thanh',
              onPressed: onQuality,
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.image_outlined,
              tooltip: 'Sửa ảnh bìa',
              onPressed: onEdit,
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.lyrics_outlined,
              tooltip: 'Lời bài hát',
              onPressed: onLyrics,
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.queue_music_rounded,
              tooltip: 'Danh sách chờ',
              onPressed: onQueue,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.song,
    required this.currentIndex,
    required this.queueLength,
    required this.compact,
  });

  final Song song;
  final int? currentIndex;
  final int queueLength;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      if (currentIndex != null) '${currentIndex! + 1}/$queueLength',
      song.extension.isEmpty ? 'AUDIO' : song.extension,
      if (song.bitrateKbps != null) '${song.bitrateKbps} kbps',
      if (!compact) formatBytes(song.fileSize),
    ];
    return Text(
      items.join('  •  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.playerController,
    required this.compact,
  });

  final PlayerController playerController;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassIconButton(
          icon: Icons.shuffle_rounded,
          tooltip: 'Trộn bài',
          selected: playerController.shuffleEnabled,
          size: compact ? 42 : 45,
          onPressed: playerController.toggleShuffle,
        ),
        GlassIconButton(
          icon: Icons.skip_previous_rounded,
          tooltip: 'Bài trước',
          size: compact ? 47 : 51,
          onPressed: playerController.previous,
        ),
        SizedBox.square(
          dimension: compact ? 66 : 74,
          child: GestureDetector(
            onTap: playerController.playOrPause,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.graphite.withValues(alpha: .96),
                border: Border.all(color: Colors.white.withValues(alpha: .82)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .20),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: .55),
                    blurRadius: 8,
                    offset: const Offset(-3, -3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  playerController.player.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: compact ? 38 : 43,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        GlassIconButton(
          icon: Icons.skip_next_rounded,
          tooltip: 'Bài tiếp theo',
          size: compact ? 47 : 51,
          onPressed: playerController.next,
        ),
        GlassIconButton(
          icon: playerController.loopMode == LoopMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          tooltip: 'Lặp bài',
          selected: playerController.loopMode != LoopMode.off,
          size: compact ? 42 : 45,
          onPressed: playerController.cycleLoopMode,
        ),
      ],
    );
  }
}

class _BottomTools extends StatelessWidget {
  const _BottomTools({
    required this.song,
    required this.libraryService,
    required this.playerController,
    required this.onSleepTimer,
  });

  final Song song;
  final LibraryService libraryService;
  final PlayerController playerController;
  final VoidCallback onSleepTimer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GlassIconButton(
            tooltip: 'Yêu thích',
            onPressed: () => libraryService.toggleFavorite(song.id),
            selected: song.isFavorite,
            size: 41,
            icon: song.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
          ),
          GlassIconButton(
            tooltip: 'AirPlay',
            size: 41,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mở Control Center của iPhone để chọn AirPlay hoặc tai nghe.',
                  ),
                ),
              );
            },
            icon: Icons.airplay_rounded,
          ),
          GlassIconButton(
            tooltip: 'Hẹn giờ tắt nhạc',
            size: 41,
            selected: playerController.sleepEndsAt != null,
            onPressed: onSleepTimer,
            icon: Icons.bedtime_outlined,
          ),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
