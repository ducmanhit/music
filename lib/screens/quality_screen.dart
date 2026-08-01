import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/song_artwork.dart';
import '../widgets/studio_widgets.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(title: const Text('Thông tin âm thanh')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            libraryService,
            playerController,
          ]),
          builder: (context, _) {
            final song = playerController.currentSong;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                if (song == null)
                  const EmptyState(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Chưa có bài hát đang phát',
                    message: 'Phát một bài hát để xem thông tin file.',
                    compact: true,
                  )
                else
                  _CurrentTrackCard(song: song),
                const SectionHeader(
                  title: 'Đường tín hiệu',
                  padding: EdgeInsets.fromLTRB(0, 28, 0, 12),
                ),
                RoundedSurface(
                  padding: EdgeInsets.zero,
                  child: const Column(
                    children: [
                      SettingsRow(
                        icon: Icons.equalizer_rounded,
                        title: 'Equalizer',
                        subtitle: 'Không áp dụng',
                      ),
                      GroupDivider(),
                      SettingsRow(
                        icon: Icons.memory_rounded,
                        title: 'Audio engine',
                        subtitle: 'Bộ giải mã hệ thống iOS',
                      ),
                      GroupDivider(),
                      SettingsRow(
                        icon: Icons.volume_up_rounded,
                        title: 'Điều khiển âm lượng',
                        subtitle: 'Theo ứng dụng',
                      ),
                    ],
                  ),
                ),
                const SectionHeader(
                  title: 'Khả năng phát',
                  padding: EdgeInsets.fromLTRB(0, 28, 0, 12),
                ),
                RoundedSurface(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SettingsRow(
                        icon: Icons.offline_bolt_outlined,
                        title: 'Phát hoàn toàn offline',
                        subtitle: 'Không cần mạng sau khi nhập file',
                      ),
                      const GroupDivider(),
                      const SettingsRow(
                        icon: Icons.lock_clock_outlined,
                        title: 'Phát nền và màn hình khóa',
                        subtitle: 'Hỗ trợ Control Center và tai nghe',
                      ),
                      const GroupDivider(),
                      SettingsRow(
                        icon: Icons.audio_file_outlined,
                        title: 'Định dạng hỗ trợ',
                        subtitle: LibraryService.supportedExtensions
                            .map((item) => item.toUpperCase())
                            .join(', '),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CurrentTrackCard extends StatelessWidget {
  const _CurrentTrackCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      song.extension,
      if (song.bitrateKbps != null) '${song.bitrateKbps} kbps',
      if (song.sampleRate != null) '${song.sampleRate} Hz',
    ];
    return RoundedSurface(
      child: Column(
        children: [
          Row(
            children: [
              SongArtwork(
                song: song,
                size: 82,
                borderRadius: 20,
                showBorder: false,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Info(label: 'Định dạng', value: details.join(' • '))),
              const SizedBox(width: 12),
              Expanded(child: _Info(label: 'Thời lượng', value: formatDuration(song.duration))),
            ],
          ),
          const SizedBox(height: 12),
          _Info(label: 'Dung lượng', value: formatBytes(song.fileSize)),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.tokens.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
