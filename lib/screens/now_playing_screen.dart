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
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([libraryService, playerController]),
          builder: (context, _) {
            final queueSong = playerController.currentSong;
            if (queueSong == null) {
              return const Center(child: Text('Chưa có bài đang phát'));
            }
            final song = libraryService.songs
                    .where((item) => item.id == queueSong.id)
                    .firstOrNull ??
                queueSong;
            final duration = playerController.player.duration ?? song.duration;
            final position = playerController.player.position;

            return Column(
              children: [
                _TopBar(
                  song: song,
                  onClose: () => Navigator.pop(context),
                  onLyrics: () => _showLyrics(context, song),
                  onQuality: () => _showQuality(context, song),
                  onQueue: () => _showQueue(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final size = constraints.maxWidth.clamp(240.0, 430.0);
                            return SongArtwork(
                              song: song,
                              size: size,
                              borderRadius: 22,
                            );
                          },
                        ),
                        const SizedBox(height: 34),
                        Text(
                          song.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              text: playerController.currentIndex == null
                                  ? '—'
                                  : '${playerController.currentIndex! + 1}/${playerController.queue.length}',
                            ),
                            _InfoChip(text: song.extension.isEmpty ? 'AUDIO' : song.extension),
                            if (song.bitrateKbps != null)
                              _InfoChip(
                                text: '${song.bitrateKbps} kbps',
                                highlighted: true,
                              ),
                            _InfoChip(text: formatBytes(song.fileSize)),
                          ],
                        ),
                        const SizedBox(height: 22),
                        WaveformSeekBar(
                          position: position,
                          duration: duration,
                          onSeek: playerController.seek,
                        ),
                        const SizedBox(height: 20),
                        _PlaybackControls(playerController: playerController),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: 'Yêu thích',
                              onPressed: () => libraryService.toggleFavorite(song.id),
                              iconSize: 29,
                              color: song.isFavorite ? AppColors.accent : AppColors.text,
                              icon: Icon(
                                song.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                              ),
                            ),
                            IconButton(
                              tooltip: 'AirPlay',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Mở Control Center của iPhone để chọn AirPlay hoặc tai nghe.',
                                    ),
                                  ),
                                );
                              },
                              iconSize: 29,
                              icon: const Icon(Icons.airplay_rounded),
                            ),
                            IconButton(
                              tooltip: 'Hẹn giờ tắt nhạc',
                              onPressed: () => _showSleepTimer(context),
                              iconSize: 29,
                              color: playerController.sleepEndsAt != null
                                  ? AppColors.accent
                                  : AppColors.text,
                              icon: const Icon(Icons.bedtime_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        builder: (context, controller) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Danh sách chờ',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: playerController.queue.length,
                  itemBuilder: (context, index) {
                    final song = playerController.queue[index];
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index == playerController.currentIndex
                            ? AppColors.accentDark
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SongTile(
                        song: song,
                        dense: true,
                        onTap: () async {
                          await playerController.player.seek(Duration.zero, index: index);
                          await playerController.player.play();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showLyrics(BuildContext context, Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .95,
        builder: (context, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lời bài hát', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
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
            const Text('Thông tin âm thanh', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            _QualityRow(label: 'Định dạng', value: song.extension.isEmpty ? 'Không rõ' : song.extension),
            _QualityRow(label: 'Bitrate', value: song.bitrateKbps == null ? 'Không rõ' : '${song.bitrateKbps} kbps'),
            _QualityRow(label: 'Sample rate', value: song.sampleRate == null ? 'Không rõ' : '${(song.sampleRate! / 1000).toStringAsFixed(1)} kHz'),
            _QualityRow(label: 'Dung lượng', value: formatBytes(song.fileSize)),
            const SizedBox(height: 12),
            const Text(
              'Âm thanh được phát qua hệ thống âm thanh của iOS. Ứng dụng không tuyên bố bit-perfect khi dùng loa hoặc cổng tích hợp.',
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
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
                title: Text('Hẹn giờ tắt nhạc', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              for (final minutes in [10, 20, 30, 45, 60, 90])
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('$minutes phút'),
                  onTap: () => Navigator.pop(context, Duration(minutes: minutes)),
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
    playerController.setSleepTimer(selected == Duration.zero ? null : selected);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.song,
    required this.onClose,
    required this.onLyrics,
    required this.onQuality,
    required this.onQueue,
  });

  final Song song;
  final VoidCallback onClose;
  final VoidCallback onLyrics;
  final VoidCallback onQuality;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(onPressed: onClose, icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 34)),
          IconButton(onPressed: onQuality, icon: const Icon(Icons.diamond_outlined)),
          const Spacer(),
          IconButton(onPressed: onLyrics, icon: const Icon(Icons.lyrics_outlined)),
          IconButton(onPressed: onQueue, icon: const Icon(Icons.queue_music_rounded)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'file', child: Text(song.fileName)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.playerController});

  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: playerController.toggleShuffle,
          color: playerController.shuffleEnabled ? AppColors.accent : AppColors.muted,
          icon: const Icon(Icons.shuffle_rounded),
        ),
        IconButton(
          onPressed: playerController.previous,
          iconSize: 40,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(.28),
                blurRadius: 28,
                spreadRadius: 5,
              ),
            ],
          ),
          child: IconButton(
            onPressed: playerController.playOrPause,
            iconSize: 45,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF07110F),
            icon: Icon(
              playerController.player.playing
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
            ),
          ),
        ),
        IconButton(
          onPressed: playerController.next,
          iconSize: 40,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        IconButton(
          onPressed: playerController.cycleLoopMode,
          color: playerController.loopMode == LoopMode.off
              ? AppColors.muted
              : AppColors.accent,
          icon: Icon(
            playerController.loopMode == LoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, this.highlighted = false});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.accentDark : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            color: highlighted ? AppColors.accent : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
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
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
