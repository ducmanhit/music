import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../services/wifi_transfer_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'wifi_transfer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
    required this.wifiTransferService,
  });

  final LibraryService libraryService;
  final PlayerController playerController;
  final WifiTransferService wifiTransferService;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([libraryService, playerController, wifiTransferService]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            children: [
              const Text(
                'Cài đặt',
                style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -.8),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                icon: Icons.play_circle_outline_rounded,
                title: 'Phát nhạc',
                initiallyExpanded: true,
                children: [
                  _VolumeTile(playerController: playerController),
                  ListTile(
                    leading: const Icon(Icons.bedtime_outlined, color: AppColors.muted),
                    title: const Text('Hẹn giờ tắt nhạc'),
                    subtitle: Text(
                      playerController.sleepEndsAt == null
                          ? 'Tắt'
                          : 'Đang hẹn đến ${_formatClock(playerController.sleepEndsAt!)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSleepTimer(context),
                  ),
                  const ListTile(
                    leading: Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                    title: Text('Phát nền & màn hình khóa'),
                    subtitle: Text('Đã bật sẵn'),
                  ),
                ],
              ),
              const _SettingsSection(
                icon: Icons.notifications_none_rounded,
                title: 'Thông báo',
                children: [
                  ListTile(
                    leading: Icon(Icons.headphones_rounded, color: AppColors.muted),
                    title: Text('Control Center & tai nghe'),
                    subtitle: Text('Phát, dừng và chuyển bài từ hệ thống iOS'),
                  ),
                ],
              ),
              const _SettingsSection(
                icon: Icons.palette_outlined,
                title: 'Giao diện',
                children: [
                  ListTile(
                    leading: Icon(Icons.dark_mode_outlined, color: AppColors.muted),
                    title: Text('Chủ đề tối'),
                    subtitle: Text('Tối ưu cho màn hình OLED'),
                    trailing: Icon(Icons.check_circle_rounded, color: AppColors.accent),
                  ),
                ],
              ),
              _SettingsSection(
                icon: Icons.wifi_tethering_rounded,
                title: 'Truyền nhạc qua Wi‑Fi',
                children: [
                  ListTile(
                    leading: Icon(
                      wifiTransferService.isRunning ? Icons.wifi_rounded : Icons.upload_file_rounded,
                      color: AppColors.muted,
                    ),
                    title: const Text('Truyền nhạc qua Wi‑Fi'),
                    subtitle: Text(
                      wifiTransferService.isRunning
                          ? wifiTransferService.url ?? 'Đang hoạt động'
                          : 'Thêm nhạc từ máy tính qua trình duyệt',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WifiTransferScreen(service: wifiTransferService),
                      ),
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                icon: Icons.storage_rounded,
                title: 'Bộ nhớ',
                children: [
                  FutureBuilder<int>(
                    future: libraryService.storageBytes(),
                    builder: (context, snapshot) => ListTile(
                      leading: const Icon(Icons.library_music_outlined, color: AppColors.muted),
                      title: const Text('Nhạc trong ứng dụng'),
                      subtitle: Text('${libraryService.songs.length} bài hát'),
                      trailing: Text(snapshot.hasData ? formatBytes(snapshot.data!) : 'Đang tính...'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
                    title: const Text('Xóa toàn bộ thư viện', style: TextStyle(color: AppColors.danger)),
                    subtitle: const Text('Xóa file nhạc và playlist trong ứng dụng'),
                    onTap: () => _clearLibrary(context),
                  ),
                ],
              ),
              const _SettingsSection(
                icon: Icons.language_rounded,
                title: 'Ngôn ngữ',
                children: [
                  ListTile(
                    leading: Icon(Icons.translate_rounded, color: AppColors.muted),
                    title: Text('Tiếng Việt'),
                    trailing: Icon(Icons.check_circle_rounded, color: AppColors.accent),
                  ),
                ],
              ),
              const _SettingsSection(
                icon: Icons.info_outline_rounded,
                title: 'Giới thiệu',
                children: [
                  ListTile(
                    leading: Icon(Icons.music_note_rounded, color: AppColors.muted),
                    title: Text('Offline Music'),
                    subtitle: Text('Phiên bản 2.0.0 • Flutter'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Ứng dụng phát file âm thanh do bạn tự nhập. Không tải nhạc từ Spotify, Apple Music hoặc YouTube.',
                      style: TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatClock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _showSleepTimer(BuildContext context) async {
    final duration = await showModalBottomSheet<Duration?>(
      context: context,
      builder: (context) => SafeArea(
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
    );
    if (duration == null) return;
    playerController.setSleepTimer(duration == Duration.zero ? null : duration);
  }

  Future<void> _clearLibrary(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ thư viện?'),
        content: const Text('Tất cả file nhạc đã nhập và playlist sẽ bị xóa vĩnh viễn khỏi ứng dụng.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa tất cả')),
        ],
      ),
    );
    if (confirmed != true) return;
    await playerController.setQueue(const []);
    await libraryService.clearLibrary();
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.only(bottom: 4),
        leading: Icon(icon, color: AppColors.accent),
        title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.muted,
        children: children,
      ),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.playerController});
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.volume_up_outlined, color: AppColors.muted),
      title: const Text('Âm lượng ứng dụng'),
      subtitle: Slider(
        value: playerController.player.volume,
        onChanged: playerController.setVolume,
      ),
      trailing: Text('${(playerController.player.volume * 100).round()}%'),
    );
  }
}
