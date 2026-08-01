import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_modal.dart';
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
    return AppPage(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[libraryService, playerController]),
        builder: (context, _) {
          final song = playerController.currentSong;
          return CustomScrollView(
            key: const PageStorageKey<String>('quality-scroll'),
            slivers: [
              const SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: 'Playback',
                  title: 'Âm thanh',
                  subtitle: 'Thông tin file và điều khiển phát nhạc.',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: song == null
                      ? const EmptyState(
                          icon: Icons.graphic_eq_rounded,
                          title: 'Chưa có bài hát đang phát',
                          message: 'Phát một bài hát để xem thông tin âm thanh.',
                          compact: true,
                        )
                      : _CurrentTrackCard(song: song),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Điều khiển',
                  subtitle: 'Các cài đặt áp dụng ngay cho phiên nghe hiện tại',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: SurfaceCard(
                    child: Column(
                      children: [
                        _VolumeControl(playerController: playerController),
                        const Divider(height: 25),
                        SettingsRow(
                          icon: Icons.timer_outlined,
                          title: 'Hẹn giờ tắt nhạc',
                          subtitle: _sleepTimerText(playerController.sleepEndsAt),
                          onTap: () => _chooseSleepTimer(context),
                        ),
                        const Divider(height: 1, indent: 64),
                        SettingsRow(
                          icon: Icons.shuffle_rounded,
                          title: 'Phát ngẫu nhiên',
                          subtitle: playerController.shuffleEnabled ? 'Đang bật' : 'Đang tắt',
                          trailing: Switch(
                            value: playerController.shuffleEnabled,
                            onChanged: (_) => playerController.toggleShuffle(),
                          ),
                          onTap: playerController.toggleShuffle,
                        ),
                        const Divider(height: 1, indent: 64),
                        SettingsRow(
                          icon: Icons.repeat_rounded,
                          title: 'Chế độ lặp',
                          subtitle: _loopModeLabel(playerController.loopMode.name),
                          onTap: playerController.cycleLoopMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Khả năng phát',
                  subtitle: 'Ứng dụng giữ nguyên file gốc và dùng bộ giải mã hệ thống',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverToBoxAdapter(
                  child: SurfaceCard(
                    child: Column(
                      children: [
                        const _CapabilityRow(
                          icon: Icons.offline_bolt_outlined,
                          title: 'Phát hoàn toàn offline',
                          detail: 'Không cần mạng sau khi nhập file',
                        ),
                        const Divider(height: 25),
                        const _CapabilityRow(
                          icon: Icons.lock_clock_outlined,
                          title: 'Phát nền và màn hình khóa',
                          detail: 'Điều khiển bằng Control Center và tai nghe',
                        ),
                        const Divider(height: 25),
                        _CapabilityRow(
                          icon: Icons.audio_file_outlined,
                          title: 'Định dạng thư viện',
                          detail: LibraryService.supportedExtensions
                              .map((extension) => extension.toUpperCase())
                              .join(', '),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _chooseSleepTimer(BuildContext context) async {
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
    if (selected == null) return;
    if (selected == 'off') {
      playerController.setSleepTimer(null);
    } else {
      playerController.setSleepTimer(Duration(minutes: int.parse(selected)));
    }
  }

  String _sleepTimerText(DateTime? end) {
    if (end == null) return 'Đang tắt';
    final remaining = end.difference(DateTime.now());
    if (remaining.isNegative) return 'Đang tắt';
    return 'Còn khoảng ${remaining.inMinutes + 1} phút';
  }

  String _loopModeLabel(String value) => switch (value) {
        'one' => 'Lặp một bài',
        'all' => 'Lặp danh sách',
        _ => 'Không lặp',
      };
}

class _CurrentTrackCard extends StatelessWidget {
  const _CurrentTrackCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SongArtwork(song: song, size: 82, borderRadius: 18),
              const SizedBox(width: 16),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DataCell(
                  label: 'Định dạng',
                  value: song.extension.isEmpty ? '—' : song.extension,
                ),
              ),
              Expanded(
                child: _DataCell(
                  label: 'Bitrate',
                  value: song.bitrateKbps == null ? '—' : '${song.bitrateKbps}\nkbps',
                ),
              ),
              Expanded(
                child: _DataCell(
                  label: 'Sample rate',
                  value: song.sampleRate == null
                      ? '—'
                      : '${(song.sampleRate! / 1000).toStringAsFixed(1)}\nkHz',
                ),
              ),
              Expanded(
                child: _DataCell(
                  label: 'Thời lượng',
                  value: formatDuration(song.duration),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: context.tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({required this.playerController});

  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final volume = playerController.player.volume;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.volume_up_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text('Âm lượng', style: Theme.of(context).textTheme.titleMedium)),
            Text('${(volume * 100).round()}%', style: TextStyle(color: context.tokens.textMuted)),
          ],
        ),
        Slider(value: volume, onChanged: playerController.setVolume),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.icon, required this.title, required this.detail});

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.tokens.accentSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
