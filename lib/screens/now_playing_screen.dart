import 'dart:io';

import 'package:flutter/cupertino.dart';
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
    return AnimatedBuilder(
      animation: Listenable.merge([libraryService, playerController]),
      builder: (context, _) {
        final queued = playerController.currentSong;
        if (queued == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBackdrop(
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.music_note_2, size: 48),
                      const SizedBox(height: 14),
                      const Text(
                        'Chưa có bài đang phát',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final song = libraryService.songById(queued.id) ?? queued;
        final duration = playerController.player.duration ?? song.duration;
        final position = playerController.player.position;
        final artworkPath = song.artworkPath;
        final artworkProvider = artworkPath != null && File(artworkPath).existsSync()
            ? FileImage(File(artworkPath))
            : null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppBackdrop(
            artwork: artworkProvider,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  final artworkSize = (constraints.maxWidth - 66)
                      .clamp(220.0, compact ? 286.0 : 330.0)
                      .toDouble();

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      compact ? 6 : 9,
                      14,
                      compact ? 8 : 12,
                    ),
                    child: Column(
                      children: [
                        _TopBar(
                          onBack: () => Navigator.pop(context),
                          onQueue: () => _showQueue(context),
                          onEdit: () => _openEditor(context, song),
                          onMore: () => _showMore(context, song),
                        ),
                        SizedBox(height: compact ? 8 : 15),
                        Expanded(
                          child: Center(
                            child: Hero(
                              tag: 'now-playing-art-${song.id}',
                              child: GlassPanel(
                                borderRadius: compact ? 33 : 38,
                                blur: 28,
                                opacity: .28,
                                shadow: true,
                                padding: const EdgeInsets.all(7),
                                child: SongArtwork(
                                  song: song,
                                  size: artworkSize,
                                  borderRadius: compact ? 27 : 31,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 13),
                        _PlayerPanel(
                          song: song,
                          duration: duration,
                          position: position,
                          compact: compact,
                          libraryService: libraryService,
                          playerController: playerController,
                          onLyrics: () => _showLyrics(context, song),
                          onQuality: () => _showQuality(context, song),
                          onSleep: () => _showSleepTimer(context),
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

  void _openEditor(BuildContext context, Song song) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LiquidBottomSheet(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          minChildSize: .42,
          maxChildSize: .94,
          builder: (context, controller) => Column(
            children: [
              const SizedBox(height: 12),
              const _SheetHandle(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Danh sách chờ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: playerController.queue.length,
                  itemBuilder: (context, index) {
                    final queued = playerController.queue[index];
                    final song = libraryService.songById(queued.id) ?? queued;
                    final selected = index == playerController.currentIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: .56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(19),
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
      ),
    );
  }

  Future<void> _showMore(BuildContext context, Song song) async {
    final rootContext = context;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LiquidBottomSheet(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(CupertinoIcons.pencil),
                  title: const Text('Sửa ảnh bìa & thông tin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openEditor(rootContext, song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lyrics_outlined),
                  title: const Text('Lời bài hát'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showLyrics(rootContext, song);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.info_circle),
                  title: const Text('Thông tin âm thanh'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showQuality(rootContext, song);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLyrics(BuildContext context, Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LiquidBottomSheet(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          maxChildSize: .95,
          builder: (context, controller) => Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _SheetHandle()),
                const SizedBox(height: 16),
                const Text(
                  'Lời bài hát',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(song.title, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Text(
                      song.lyrics?.trim().isNotEmpty == true
                          ? song.lyrics!
                          : 'File nhạc này không có lời bài hát trong metadata.',
                      style: const TextStyle(fontSize: 18, height: 1.68),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showQuality(BuildContext context, Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LiquidBottomSheet(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _SheetHandle()),
                const SizedBox(height: 16),
                const Text(
                  'Thông tin âm thanh',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
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
                _QualityRow(
                  label: 'Dung lượng',
                  value: formatBytes(song.fileSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context) async {
    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LiquidBottomSheet(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 10),
                const ListTile(
                  title: Text(
                    'Hẹn giờ tắt nhạc',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                for (final minutes in [10, 20, 30, 45, 60, 90])
                  ListTile(
                    leading: const Icon(CupertinoIcons.timer),
                    title: Text('$minutes phút'),
                    onTap: () =>
                        Navigator.pop(context, Duration(minutes: minutes)),
                  ),
                ListTile(
                  leading: const Icon(CupertinoIcons.clear_circled),
                  title: const Text('Tắt hẹn giờ'),
                  onTap: () => Navigator.pop(context, Duration.zero),
                ),
              ],
            ),
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
    required this.onBack,
    required this.onQueue,
    required this.onEdit,
    required this.onMore,
  });

  final VoidCallback onBack;
  final VoidCallback onQueue;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(icon: CupertinoIcons.chevron_down, onPressed: onBack),
        const Spacer(),
        GlassIconButton(
          icon: CupertinoIcons.music_note_list,
          onPressed: onQueue,
        ),
        const SizedBox(width: 8),
        GlassIconButton(icon: CupertinoIcons.pencil, onPressed: onEdit),
        const SizedBox(width: 8),
        GlassIconButton(icon: CupertinoIcons.ellipsis, onPressed: onMore),
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.song,
    required this.duration,
    required this.position,
    required this.compact,
    required this.libraryService,
    required this.playerController,
    required this.onLyrics,
    required this.onQuality,
    required this.onSleep,
  });

  final Song song;
  final Duration duration;
  final Duration position;
  final bool compact;
  final LibraryService libraryService;
  final PlayerController playerController;
  final VoidCallback onLyrics;
  final VoidCallback onQuality;
  final VoidCallback onSleep;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: compact ? 31 : 35,
      blur: 32,
      opacity: .48,
      shadow: true,
      padding: EdgeInsets.fromLTRB(
        compact ? 17 : 20,
        compact ? 14 : 18,
        compact ? 17 : 20,
        compact ? 12 : 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              letterSpacing: -.55,
            ),
          ),
          SizedBox(height: compact ? 3 : 5),
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: compact ? 14 : 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 6 : 9),
          _MetadataLine(
            song: song,
            currentIndex: playerController.currentIndex,
            queueLength: playerController.queue.length,
          ),
          SizedBox(height: compact ? 4 : 7),
          WaveformSeekBar(
            position: position,
            duration: duration,
            onSeek: playerController.seek,
            waveHeight: compact ? 48 : 58,
          ),
          SizedBox(height: compact ? 1 : 5),
          _PlaybackControls(
            playerController: playerController,
            compact: compact,
          ),
          SizedBox(height: compact ? 5 : 10),
          _BottomTools(
            song: song,
            libraryService: libraryService,
            onLyrics: onLyrics,
            onQuality: onQuality,
            onSleep: onSleep,
          ),
        ],
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.song,
    required this.currentIndex,
    required this.queueLength,
  });

  final Song song;
  final int? currentIndex;
  final int queueLength;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (queueLength > 0 && currentIndex != null)
        '${currentIndex! + 1}/$queueLength',
      if (song.extension.isNotEmpty) song.extension,
      if (song.bitrateKbps != null) '${song.bitrateKbps} kbps',
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 5,
      children: [
        for (final part in parts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .48),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: .68)),
            ),
            child: Text(
              part,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
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
    final loopIcon = playerController.loopMode == LoopMode.one
        ? Icons.repeat_one_rounded
        : Icons.repeat_rounded;
    final loopActive = playerController.loopMode != LoopMode.off;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundControl(
          icon: CupertinoIcons.shuffle,
          active: playerController.shuffleEnabled,
          onTap: playerController.toggleShuffle,
          size: compact ? 43 : 47,
        ),
        _PlainControl(
          icon: Icons.skip_previous_rounded,
          onTap: playerController.previous,
          size: compact ? 31 : 35,
        ),
        _PlayButton(
          playing: playerController.player.playing,
          onTap: playerController.playOrPause,
          size: compact ? 67 : 74,
        ),
        _PlainControl(
          icon: Icons.skip_next_rounded,
          onTap: playerController.next,
          size: compact ? 31 : 35,
        ),
        _RoundControl(
          icon: loopIcon,
          active: loopActive,
          onTap: playerController.cycleLoopMode,
          size: compact ? 43 : 47,
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.onTap,
    required this.size,
  });

  final bool playing;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.graphite,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .36)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 21,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          color: Colors.white,
          size: size * .40,
        ),
      ),
    );
  }
}

class _PlainControl extends StatelessWidget {
  const _PlainControl({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: size, color: AppColors.graphite),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: .74)
              : Colors.white.withValues(alpha: .30),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .66)),
        ),
        child: Icon(
          icon,
          size: size * .43,
          color: active ? AppColors.accent : AppColors.graphiteSoft,
        ),
      ),
    );
  }
}

class _BottomTools extends StatelessWidget {
  const _BottomTools({
    required this.song,
    required this.libraryService,
    required this.onLyrics,
    required this.onQuality,
    required this.onSleep,
  });

  final Song song;
  final LibraryService libraryService;
  final VoidCallback onLyrics;
  final VoidCallback onQuality;
  final VoidCallback onSleep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ToolButton(
          icon: song.isFavorite
              ? CupertinoIcons.heart_fill
              : CupertinoIcons.heart,
          active: song.isFavorite,
          onTap: () => libraryService.toggleFavorite(song.id),
        ),
        _ToolButton(icon: Icons.lyrics_outlined, onTap: onLyrics),
        _ToolButton(icon: CupertinoIcons.info_circle, onTap: onQuality),
        _ToolButton(icon: CupertinoIcons.moon, onTap: onSleep),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Icon(
          icon,
          size: 23,
          color: active ? AppColors.danger : AppColors.graphiteSoft,
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
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LiquidBottomSheet extends StatelessWidget {
  const _LiquidBottomSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GlassPanel(
        borderRadius: 36,
        blur: 34,
        opacity: .78,
        child: child,
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0x553C3C43),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
