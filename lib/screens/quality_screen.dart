import 'package:flutter/cupertino.dart';
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
          animation: Listenable.merge([libraryService, playerController]),
          builder: (context, _) {
            final queued = playerController.currentSong;
            final song = queued == null
                ? null
                : libraryService.songById(queued.id) ?? queued;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 160),
              children: [
                const _Header(),
                const SizedBox(height: 28),
                GlassPanel(
                  padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
                  borderRadius: 30,
                  blur: 30,
                  opacity: .38,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.graphite,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .14),
                              blurRadius: 18,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.waveform,
                          color: Colors.white,
                          size: 28,
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
                                letterSpacing: -.25,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Không áp dụng EQ hoặc hiệu ứng giả lập.',
                              style: TextStyle(
                                color: AppColors.muted,
                                height: 1.35,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _InfoGroup(
                  title: 'ĐƯỜNG TÍN HIỆU',
                  children: [
                    _SignalRow(
                      icon: CupertinoIcons.slider_horizontal_3,
                      label: 'Equalizer',
                      value: 'Không áp dụng',
                    ),
                    _RowDivider(),
                    _SignalRow(
                      icon: CupertinoIcons.waveform,
                      label: 'Audio engine',
                      value: 'Hệ thống iOS',
                    ),
                    _RowDivider(),
                    _SignalRow(
                      icon: CupertinoIcons.speaker_2,
                      label: 'Âm lượng',
                      value: 'Theo ứng dụng',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoGroup(
                  title: 'BÀI ĐANG PHÁT',
                  children: song == null
                      ? const [
                          Padding(
                            padding: EdgeInsets.all(18),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Chưa có bài đang phát',
                                style: TextStyle(color: AppColors.muted),
                              ),
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
                const SizedBox(height: 24),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Bitrate và sample rate được đọc từ metadata của file. Một số bài có thể không lưu đầy đủ dữ liệu.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.45,
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
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÂM THANH',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.15,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Chất lượng',
            style: TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.25,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Thông tin nguồn phát và đường tín hiệu âm thanh.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        GlassPanel(
          padding: EdgeInsets.zero,
          borderRadius: 28,
          blur: 28,
          opacity: .35,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .54),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: .70)),
            ),
            child: Icon(icon, color: AppColors.graphite, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
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
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1),
    );
  }
}
