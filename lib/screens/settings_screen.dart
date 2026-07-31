import 'package:flutter/cupertino.dart';
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
          animation: Listenable.merge([libraryService, playerController]),
          builder: (context, _) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 160),
              children: [
                const _LargeHeader(
                  eyebrow: 'OFFLINE MUSIC',
                  title: 'Cài đặt',
                  subtitle: 'Phát nhạc, thư viện và điều khiển trên iPhone.',
                ),
                const SizedBox(height: 28),
                _SettingsGroup(
                  title: 'PHÁT NHẠC',
                  children: [
                    _VolumeTile(playerController: playerController),
                    const _GroupDivider(),
                    _SettingsTile(
                      icon: CupertinoIcons.moon,
                      title: 'Hẹn giờ tắt nhạc',
                      subtitle: playerController.sleepEndsAt == null
                          ? 'Đang tắt'
                          : 'Đến ${_formatClock(playerController.sleepEndsAt!)}',
                      onTap: () => _showSleepTimer(context),
                    ),
                    const _GroupDivider(),
                    const _SettingsTile(
                      icon: CupertinoIcons.lock,
                      title: 'Phát nền & màn hình khóa',
                      subtitle: 'Luôn sẵn sàng trên iOS',
                      trailing: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsGroup(
                  title: 'THƯ VIỆN',
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.plus,
                      title: 'Nhập thêm nhạc',
                      subtitle: 'Chọn file âm thanh từ ứng dụng Files',
                      onTap: () => showImportMusicSheet(
                        context,
                        libraryService: libraryService,
                      ),
                    ),
                    const _GroupDivider(),
                    FutureBuilder<int>(
                      future: libraryService.storageBytes(),
                      builder: (context, snapshot) => _SettingsTile(
                        icon: CupertinoIcons.archivebox,
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
                    const _GroupDivider(),
                    _SettingsTile(
                      icon: CupertinoIcons.delete,
                      iconColor: AppColors.danger,
                      titleColor: AppColors.danger,
                      title: 'Xóa toàn bộ thư viện',
                      subtitle: 'Xóa nhạc, ảnh bìa và playlist trong app',
                      onTap: () => _clearLibrary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SettingsGroup(
                  title: 'GIAO DIỆN',
                  children: [
                    _SettingsTile(
                      icon: Icons.blur_on_rounded,
                      title: 'Liquid Glass',
                      subtitle: 'Kính trắng trong, tối giản và đồng bộ iOS',
                      trailing: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    _GroupDivider(),
                    _SettingsTile(
                      icon: CupertinoIcons.photo,
                      title: 'Ảnh bìa tùy chỉnh',
                      subtitle: 'Chọn ảnh hoặc tìm ảnh bìa online',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SettingsGroup(
                  title: 'THIẾT BỊ',
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.headphones,
                      title: 'Control Center & tai nghe',
                      subtitle: 'Phát, dừng và chuyển bài từ hệ thống',
                    ),
                    _GroupDivider(),
                    _SettingsTile(
                      icon: Icons.airplay_rounded,
                      title: 'AirPlay & Bluetooth',
                      subtitle: 'Chọn thiết bị phát trong Control Center',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SettingsGroup(
                  title: 'GIỚI THIỆU',
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.music_note_2,
                      title: 'Offline Music',
                      subtitle: 'Phiên bản 8.0.0',
                    ),
                    _GroupDivider(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 15, 18, 18),
                      child: Text(
                        'Ứng dụng chỉ phát những file âm thanh do bạn tự nhập. Tìm ảnh bìa online không tải nhạc từ dịch vụ phát trực tuyến.',
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LiquidSheet(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hẹn giờ tắt nhạc',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                for (final minutes in [10, 20, 30, 45, 60, 90])
                  ListTile(
                    leading: const Icon(CupertinoIcons.timer),
                    title: Text('$minutes phút'),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
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
    if (duration == null) return;
    playerController.setSleepTimer(duration == Duration.zero ? null : duration);
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

class _LargeHeader extends StatelessWidget {
  const _LargeHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
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
          opacity: .19,
          shadow: true,
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .30),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: .34)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: .18),
              blurRadius: 10,
              spreadRadius: -4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? AppColors.graphite, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.text,
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -.15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.muted,
          height: 1.25,
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          (onTap == null
              ? null
              : const Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppColors.mutedSoft,
                  size: 18,
                )),
      onTap: onTap,
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 70),
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
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 9),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .30),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: .34)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: .18),
                  blurRadius: 10,
                  spreadRadius: -4,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.speaker_2,
              color: AppColors.graphite,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Âm lượng ứng dụng',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
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

class _LiquidSheet extends StatelessWidget {
  const _LiquidSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GlassPanel(
        borderRadius: 36,
        blur: 32,
        opacity: .62,
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
      width: 46,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0x553C3C43),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
