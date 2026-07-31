import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/import_music_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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
          builder: (context, _) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 160),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tùy chỉnh',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Quản lý phát nhạc, giao diện và bộ nhớ ứng dụng.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: playerController,
                  builder: (context, _) => _SettingsGroup(
                    title: 'PHÁT NHẠC',
                    children: [
                      _VolumeTile(playerController: playerController),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.bedtime_outlined,
                        title: 'Hẹn giờ tắt nhạc',
                        subtitle: playerController.sleepEndsAt == null
                            ? 'Đang tắt'
                            : 'Đến ${_formatClock(playerController.sleepEndsAt!)}',
                        onTap: () => _showSleepTimer(context),
                      ),
                      const _Divider(),
                      const _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Phát nền & màn hình khóa',
                        subtitle: 'Đã bật sẵn',
                        trailing: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SettingsGroup(
                  title: 'THƯ VIỆN',
                  children: [
                    _SettingsTile(
                      icon: Icons.add_rounded,
                      title: 'Nhập thêm nhạc',
                      subtitle: 'Chọn file âm thanh từ ứng dụng Files',
                      onTap: () => showImportMusicSheet(
                        context,
                        libraryService: libraryService,
                      ),
                    ),
                    const _Divider(),
                    FutureBuilder<int>(
                      future: libraryService.storageBytes(),
                      builder: (context, snapshot) => _SettingsTile(
                        icon: Icons.storage_rounded,
                        title: 'Bộ nhớ đang dùng',
                        subtitle: '${libraryService.songs.length} bài hát',
                        trailing: Text(
                          snapshot.hasData
                              ? formatBytes(snapshot.data!)
                              : 'Đang tính…',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      iconColor: AppColors.danger,
                      title: 'Xóa toàn bộ thư viện',
                      titleColor: AppColors.danger,
                      subtitle: 'Xóa nhạc, ảnh bìa và playlist trong app',
                      onTap: () => _clearLibrary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SettingsGroup(
                  title: 'GIAO DIỆN',
                  children: [
                    _SettingsTile(
                      icon: Icons.blur_on_rounded,
                      title: 'Liquid Glass sáng',
                      subtitle: 'Kính trắng trung tính, đồng bộ phong cách iOS',
                      trailing: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.image_outlined,
                      title: 'Ảnh bìa tùy chỉnh',
                      subtitle: 'Chọn ảnh hoặc tìm ảnh bìa online',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SettingsGroup(
                  title: 'ĐIỀU KHIỂN iOS',
                  children: [
                    _SettingsTile(
                      icon: Icons.headphones_rounded,
                      title: 'Control Center & tai nghe',
                      subtitle: 'Phát, dừng và chuyển bài từ hệ thống',
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.airplay_rounded,
                      title: 'AirPlay & Bluetooth',
                      subtitle: 'Chọn thiết bị phát trong Control Center',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SettingsGroup(
                  title: 'GIỚI THIỆU',
                  children: [
                    _SettingsTile(
                      icon: Icons.music_note_rounded,
                      title: 'Offline Music',
                      subtitle: 'Phiên bản 6.0.0 • Flutter',
                    ),
                    _Divider(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 17),
                      child: Text(
                        'Ứng dụng phát các file âm thanh do bạn tự nhập. Tính năng tìm ảnh bìa online chỉ tải hình ảnh và không tải nhạc từ các dịch vụ phát trực tuyến.',
                        style: TextStyle(
                          color: AppColors.muted,
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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
    );
    if (duration == null) return;
    playerController.setSleepTimer(
      duration == Duration.zero ? null : duration,
    );
  }

  Future<void> _clearLibrary(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ thư viện?'),
        content: const Text(
          'Tất cả file nhạc, ảnh bìa đã lưu và playlist sẽ bị xóa vĩnh viễn khỏi ứng dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await playerController.setQueue(const []);
    await libraryService.clearLibrary();
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

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
          opacity: .58,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 11,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.graphite).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.graphite, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, height: 1.3),
      ),
      trailing: trailing ??
          (onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedSoft,
                )),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 66),
      child: Divider(height: 1),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.playerController});

  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x19787880),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volume_up_outlined,
              color: AppColors.graphite,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Âm lượng ứng dụng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${(playerController.player.volume * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: playerController.player.volume,
                  onChanged: playerController.setVolume,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
