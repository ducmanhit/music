import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

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
    return AppBackdrop(
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: libraryService,
          builder: (context, _) => StreamBuilder<int?>(
            stream: playerController.player.currentIndexStream,
            initialData: playerController.currentIndex,
            builder: (context, snapshot) {
              final index = snapshot.data;
              final queuedSong = index != null &&
                      index >= 0 &&
                      index < playerController.queue.length
                  ? playerController.queue[index]
                  : null;
              final song = queuedSong == null
                  ? null
                  : libraryService.songById(queuedSong.id) ?? queuedSong;
              return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 160),
              children: [
                const Text(
                  'Âm thanh',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Chất lượng',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 22),
                GlassPanel(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 26,
                  blur: 18,
                  opacity: .24,
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppGradients.hero,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phát âm thanh gốc',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Không áp dụng EQ hoặc hiệu ứng giả lập.',
                              style: TextStyle(
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _InfoGroup(
                  title: 'ĐƯỜNG TÍN HIỆU',
                  children: const [
                    _SignalRow(
                      icon: Icons.equalizer_rounded,
                      label: 'Equalizer',
                      value: 'Không áp dụng',
                    ),
                    _RowDivider(),
                    _SignalRow(
                      icon: Icons.multitrack_audio_rounded,
                      label: 'Audio engine',
                      value: 'Hệ thống iOS',
                    ),
                    _RowDivider(),
                    _SignalRow(
                      icon: Icons.volume_up_outlined,
                      label: 'Âm lượng',
                      value: 'Theo ứng dụng',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoGroup(
                  title: 'BÀI ĐANG PHÁT',
                  children: song == null
                      ? const [
                          Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'Chưa có bài đang phát',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ]
                      : [
                          _DetailRow(label: 'Bài hát', value: song.title),
                          const _RowDivider(),
                          _DetailRow(
                            label: 'Định dạng',
                            value: song.extension.isEmpty
                                ? 'Không rõ'
                                : song.extension,
                          ),
                          const _RowDivider(),
                          _DetailRow(
                            label: 'Bitrate',
                            value: song.bitrateKbps == null
                                ? 'Không rõ'
                                : '${song.bitrateKbps} kbps',
                          ),
                          const _RowDivider(),
                          _DetailRow(
                            label: 'Sample rate',
                            value: song.sampleRate == null
                                ? 'Không rõ'
                                : '${(song.sampleRate! / 1000).toStringAsFixed(1)} kHz',
                          ),
                          const _RowDivider(),
                          _DetailRow(
                            label: 'Dung lượng',
                            value: formatBytes(song.fileSize),
                          ),
                        ],
                ),
                const SizedBox(height: 20),
                const _InfoGroup(
                  title: 'ĐẦU RA',
                  children: [
                    _DetailRow(label: 'Thiết bị', value: 'Do iOS quản lý'),
                    _RowDivider(),
                    _DetailRow(
                      label: 'AirPlay / Bluetooth',
                      value: 'Chọn trong Control Center',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Bitrate và sample rate được đọc từ metadata của file. Một số bài có thể không lưu đầy đủ dữ liệu.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 9),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        GlassPanel(
          padding: EdgeInsets.zero,
          borderRadius: 23,
          blur: 16,
          opacity: .22,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentDark,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.accent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 64),
      child: Divider(height: 1),
    );
  }
}
