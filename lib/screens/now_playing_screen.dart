import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_modal.dart';
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
                                borderRadius: compact ? 34 : 40,
                                blur: 38,
                                opacity: .045,
                                shadow: true,
                                pressable: false,
                                padding: const EdgeInsets.all(4),
                                child: SongArtwork(
                                  song: song,
                                  size: artworkSize,
                                  borderRadius: compact ? 30 : 36,
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
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        minChildSize: .42,
        maxChildSize: .94,
        builder: (context, controller) => Column(
          children: [
            const AppSheetHeader(
              title: 'Danh sách chờ',
              subtitle: 'Chạm vào một bài để phát ngay.',
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 18),
                itemCount: playerController.queue.length,
                separatorBuilder: (_, __) => const Divider(
                  indent: 70,
                  endIndent: 12,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final queued = playerController.queue[index];
                  final song = libraryService.songById(queued.id) ?? queued;
                  final selected = index == playerController.currentIndex;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: .07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
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
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
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

  Future<void> _showMore(BuildContext context, Song song) async {
    final selected = await showAppSelectionSheet<String>(
      context: context,
      title: song.title,
      subtitle: song.artist,
      options: const [
        AppSelectionOption(
          value: 'edit',
          title: 'Sửa ảnh bìa & thông tin',
          icon: CupertinoIcons.pencil,
        ),
        AppSelectionOption(
          value: 'lyrics',
          title: 'Lời bài hát',
          icon: Icons.lyrics_outlined,
        ),
        AppSelectionOption(
          value: 'quality',
          title: 'Thông tin âm thanh',
          icon: CupertinoIcons.info_circle,
        ),
      ],
    );
    if (!context.mounted || selected == null) return;
    switch (selected) {
      case 'edit':
        _openEditor(context, song);
        break;
      case 'lyrics':
        await _showLyrics(context, song);
        break;
      case 'quality':
        await _showQuality(context, song);
        break;
    }
  }

  Future<void> _showLyrics(BuildContext context, Song song) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        minChildSize: .48,
        maxChildSize: .95,
        builder: (context, controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: 'Lời bài hát',
              subtitle: song.title,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
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
    );
  }

  Future<void> _showQuality(BuildContext context, Song song) async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSheetHeader(
              title: 'Thông tin âm thanh',
              subtitle: 'Dữ liệu được đọc trực tiếp từ file nhạc.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _QualityRow(
                    label: 'Định dạng',
                    value: song.extension.isEmpty
                        ? 'Không rõ'
                        : song.extension,
                  ),
                  const Divider(height: 1),
                  _QualityRow(
                    label: 'Bitrate',
                    value: song.bitrateKbps == null
                        ? 'Không rõ'
                        : '${song.bitrateKbps} kbps',
                  ),
                  const Divider(height: 1),
                  _QualityRow(
                    label: 'Sample rate',
                    value: song.sampleRate == null
                        ? 'Không rõ'
                        : '${(song.sampleRate! / 1000).toStringAsFixed(1)} kHz',
                  ),
                  const Divider(height: 1),
                  _QualityRow(
                    label: 'Dung lượng',
                    value: formatBytes(song.fileSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context) async {
    final selected = await showAppSelectionSheet<Duration>(
      context: context,
      title: 'Hẹn giờ tắt nhạc',
      subtitle: 'Chọn thời gian để ứng dụng tự dừng phát.',
      options: [
        for (final minutes in [10, 20, 30, 45, 60, 90])
          AppSelectionOption(
            value: Duration(minutes: minutes),
            title: '$minutes phút',
            icon: CupertinoIcons.timer,
          ),
        const AppSelectionOption(
          value: Duration.zero,
          title: 'Tắt hẹn giờ',
          icon: CupertinoIcons.clear_circled,
        ),
      ],
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
        GlassIconButton(
          icon: CupertinoIcons.chevron_down,
          onPressed: onBack,
          size: 44,
        ),
        const Spacer(),
        GlassPanel(
          borderRadius: 24,
          blur: 38,
          opacity: .06,
          shadow: false,
          pressable: false,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TopAction(icon: CupertinoIcons.music_note_list, onTap: onQueue),
              _TopAction(icon: CupertinoIcons.pencil, onTap: onEdit),
              _TopAction(icon: CupertinoIcons.ellipsis, onTap: onMore),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.square(
        dimension: 39,
        child: Icon(icon, size: 20, color: AppColors.graphite),
      ),
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
      borderRadius: compact ? 32 : 37,
      blur: 42,
      opacity: .085,
      shadow: false,
      pressable: false,
      padding: EdgeInsets.fromLTRB(
        compact ? 17 : 21,
        compact ? 14 : 18,
        compact ? 17 : 21,
        compact ? 11 : 15,
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
              fontFamily: '.SF Pro Display',
              fontSize: compact ? 20 : 23,
              height: 1.12,
              fontWeight: FontWeight.w700,
              letterSpacing: -.58,
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
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: compact ? 7 : 10),
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
            waveHeight: compact ? 46 : 56,
          ),
          SizedBox(height: compact ? 1 : 4),
          _PlaybackControls(
            playerController: playerController,
            compact: compact,
          ),
          SizedBox(height: compact ? 6 : 10),
          GlassPanel(
            borderRadius: 24,
            blur: 34,
            opacity: .045,
            shadow: false,
            pressable: false,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _BottomTools(
              song: song,
              libraryService: libraryService,
              onLyrics: onLyrics,
              onQuality: onQuality,
              onSleep: onSleep,
            ),
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
    return Text(
      parts.join('  •  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -.1,
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
    return SizedBox.square(
      dimension: size,
      child: GlassPanel(
        borderRadius: size / 2,
        blur: 38,
        opacity: .16,
        shadow: true,
        onTap: onTap,
        child: Center(
          child: Icon(
            playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
            color: AppColors.graphite,
            size: size * .39,
          ),
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
    return SizedBox.square(
      dimension: size,
      child: GlassPanel(
        borderRadius: size / 2,
        blur: 34,
        opacity: active ? .18 : .055,
        shadow: false,
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            size: size * .43,
            color: active ? AppColors.accent : AppColors.graphiteSoft,
          ),
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