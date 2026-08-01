import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/app_preferences.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_modal.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/studio_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.libraryService,
    required this.playerController,
  });

  final AppPreferences preferences;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[preferences, libraryService, playerController]),
        builder: (context, _) => CustomScrollView(
          key: const PageStorageKey<String>('settings-scroll'),
          slivers: [
            const SliverToBoxAdapter(
              child: PageHeader(
                eyebrow: 'Ứng dụng',
                title: 'Cài đặt',
                subtitle: 'Giao diện, thư viện và tùy chọn phát nhạc.',
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Giao diện',
                subtitle: 'Chọn chế độ hiển thị phù hợp với bạn',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _ThemeSelector(preferences: preferences),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Thư viện',
                subtitle: 'Quản lý file nhạc được lưu trong ứng dụng',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: SurfaceCard(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.add_to_photos_outlined,
                        title: 'Thêm nhạc',
                        subtitle: 'Chọn file từ ứng dụng Files',
                        onTap: libraryService.isImporting
                            ? null
                            : () => showImportMusicSheet(
                                  context: context,
                                  libraryService: libraryService,
                                ),
                      ),
                      const Divider(height: 1, indent: 64),
                      SettingsRow(
                        icon: Icons.refresh_rounded,
                        title: 'Quét lại thư mục nhạc',
                        subtitle: 'Tìm file mới trong bộ nhớ của ứng dụng',
                        onTap: libraryService.isImporting
                            ? null
                            : () => _rescan(context),
                      ),
                      const Divider(height: 1, indent: 64),
                      FutureBuilder<int>(
                        future: libraryService.storageBytes(),
                        builder: (context, snapshot) => SettingsRow(
                          icon: Icons.storage_rounded,
                          title: 'Dung lượng thư viện',
                          subtitle: '${libraryService.songs.length} bài hát',
                          trailing: Text(
                            formatBytes(snapshot.data ?? 0),
                            style: TextStyle(
                              color: context.tokens.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 64),
                      SettingsRow(
                        icon: Icons.delete_sweep_outlined,
                        title: 'Xóa toàn bộ thư viện',
                        subtitle: 'Xóa file nhạc, ảnh bìa và playlist',
                        danger: true,
                        onTap: libraryService.songs.isEmpty
                            ? null
                            : () => _clearLibrary(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Phát nhạc',
                subtitle: 'Thiết lập nhanh cho phiên nghe hiện tại',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: SurfaceCard(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.timer_outlined,
                        title: 'Hẹn giờ tắt nhạc',
                        subtitle: _timerLabel(playerController.sleepEndsAt),
                        onTap: () => _chooseSleepTimer(context),
                      ),
                      const Divider(height: 1, indent: 64),
                      SettingsRow(
                        icon: Icons.restart_alt_rounded,
                        title: 'Đặt lại chế độ phát',
                        subtitle: 'Tắt ngẫu nhiên, lặp và hẹn giờ',
                        onTap: () => _resetPlayback(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Thông tin'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: SliverToBoxAdapter(
                child: SurfaceCard(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      const SettingsRow(
                        icon: Icons.music_note_rounded,
                        title: 'Offline Music Studio',
                        subtitle: 'Phiên bản 12.0.0',
                        trailing: SizedBox.shrink(),
                      ),
                      const Divider(height: 1, indent: 64),
                      SettingsRow(
                        icon: Icons.shield_outlined,
                        title: 'Quyền riêng tư',
                        subtitle: 'Thư viện được lưu cục bộ, không cần tài khoản',
                        trailing: const SizedBox.shrink(),
                      ),
                      const Divider(height: 1, indent: 64),
                      SettingsRow(
                        icon: Icons.code_rounded,
                        title: 'Nền tảng',
                        subtitle: 'Flutter · iOS · Phát nhạc offline',
                        trailing: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rescan(BuildContext context) async {
    final result = await libraryService.rescanMusicFolder();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _clearLibrary(BuildContext context) async {
    final confirmed = await showAppConfirmation(
      context: context,
      title: 'Xóa toàn bộ thư viện?',
      message: 'Tất cả file nhạc, ảnh bìa và playlist trong ứng dụng sẽ bị xóa. Thao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
      destructive: true,
    );
    if (!confirmed) return;
    await playerController.setQueue(const <Song>[]);
    await libraryService.clearLibrary();
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

  Future<void> _resetPlayback(BuildContext context) async {
    if (playerController.shuffleEnabled) await playerController.toggleShuffle();
    while (playerController.loopMode.name != 'off') {
      await playerController.cycleLoopMode();
    }
    playerController.setSleepTimer(null);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đã đặt lại chế độ phát.')));
  }

  String _timerLabel(DateTime? end) {
    if (end == null) return 'Đang tắt';
    final remaining = end.difference(DateTime.now());
    if (remaining.isNegative) return 'Đang tắt';
    return 'Còn khoảng ${remaining.inMinutes + 1} phút';
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final options = <({AppThemeChoice value, IconData icon, String title, String detail})>[
      (
        value: AppThemeChoice.system,
        icon: Icons.brightness_auto_rounded,
        title: 'Hệ thống',
        detail: 'Theo cài đặt iPhone',
      ),
      (
        value: AppThemeChoice.light,
        icon: Icons.light_mode_rounded,
        title: 'Sáng',
        detail: 'Nền sáng rõ ràng',
      ),
      (
        value: AppThemeChoice.dark,
        icon: Icons.dark_mode_rounded,
        title: 'Tối',
        detail: 'Dịu mắt ban đêm',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        if (compact) {
          return Column(
            children: [
              for (var index = 0; index < options.length; index++) ...[
                _ThemeOption(
                  option: options[index],
                  selected: preferences.themeChoice == options[index].value,
                  onTap: () => preferences.setThemeChoice(options[index].value),
                ),
                if (index < options.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              Expanded(
                child: _ThemeOption(
                  option: options[index],
                  selected: preferences.themeChoice == options[index].value,
                  onTap: () => preferences.setThemeChoice(options[index].value),
                ),
              ),
              if (index < options.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ({AppThemeChoice value, IconData icon, String title, String detail}) option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SurfaceCard(
      onTap: onTap,
      color: selected ? context.tokens.accentSoft : context.tokens.surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(option.icon, color: selected ? primary : context.tokens.textMuted),
              const Spacer(),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? primary : context.tokens.textFaint,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(option.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            option.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
