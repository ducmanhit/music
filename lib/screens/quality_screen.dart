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
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([libraryService, playerController]),
        builder: (context, _) {
          final song = playerController.currentSong;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
            children: [
              const Text(
                'Chất lượng',
                style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -.8),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond_outlined, size: 46, color: AppColors.muted),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CHẾ ĐỘ TIÊU CHUẨN iOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text(
                            'Phát file gốc qua hệ thống âm thanh của iPhone.',
                            style: TextStyle(color: AppColors.muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: true, onChanged: null),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ứng dụng không gắn nhãn “bit-perfect” vì iOS có thể đổi sample rate theo thiết bị đầu ra. Muốn xác nhận bit-perfect thật cần DAC ngoài và audio engine native chuyên dụng.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 26),
              const _SectionLabel('ĐƯỜNG TÍN HIỆU'),
              const SizedBox(height: 12),
              _SignalRow(
                icon: Icons.equalizer_rounded,
                label: 'Equalizer',
                value: 'Không áp dụng',
              ),
              const _SignalRow(
                icon: Icons.volume_up_outlined,
                label: 'Âm lượng',
                value: 'Theo ứng dụng',
              ),
              const _SignalRow(
                icon: Icons.multitrack_audio_rounded,
                label: 'Audio engine',
                value: 'AVPlayer / iOS',
              ),
              const Divider(height: 34),
              const _SectionLabel('NGUỒN'),
              const SizedBox(height: 14),
              if (song == null)
                const _EmptySignal(text: 'Không có bài đang phát')
              else ...[
                _DetailRow(label: 'Bài hát', value: song.title),
                _DetailRow(label: 'Định dạng', value: song.extension.isEmpty ? 'Không rõ' : song.extension),
                _DetailRow(
                  label: 'Bitrate',
                  value: song.bitrateKbps == null ? 'Không rõ' : '${song.bitrateKbps} kbps',
                ),
                _DetailRow(
                  label: 'Sample rate',
                  value: song.sampleRate == null
                      ? 'Không rõ'
                      : '${(song.sampleRate! / 1000).toStringAsFixed(1)} kHz',
                ),
                _DetailRow(label: 'Dung lượng', value: formatBytes(song.fileSize)),
              ],
              const Divider(height: 34),
              const _SectionLabel('NGÕ RA'),
              const SizedBox(height: 14),
              const _DetailRow(label: 'Thiết bị', value: 'Do iOS quản lý'),
              const _DetailRow(label: 'AirPlay / Bluetooth', value: 'Chọn trong Control Center'),
              const SizedBox(height: 18),
              const Text(
                'Thông tin bitrate và sample rate lấy từ metadata của file. Một số file không lưu đủ dữ liệu nên có thể hiển thị “Không rõ”.',
                style: TextStyle(color: AppColors.muted, height: 1.45),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w900, letterSpacing: 1.4),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 17))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 16))),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySignal extends StatelessWidget {
  const _EmptySignal({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 17)),
    );
  }
}
