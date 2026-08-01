import 'package:flutter/material.dart';

import '../services/app_preferences.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_modal.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/studio_widgets.dart';
import 'quality_screen.dart';

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
        animation: Listenable.merge(<Listenable>[
          preferences,
          libraryService,
          playerController,
        ]),
        builder: (context, _) {
          return CustomScrollView(
            key: const PageStorageKey<String>('settings-page'),
            slivers: [
              const SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: 'Tùy chỉnh',
                  title: 'Cài đặt',
                  subtitle: 'Quản lý giao diện, phát nhạc và bộ nhớ ứng dụng.',
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Giao diện'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: RoundedSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingsRow(
                          icon: Icons.palette_outlined,
                          title: 'Chế độ hiển thị',
                          subtitle: _themeLabel(preferences.themeChoice),
                          onTap: () => _selectTheme(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Phát nhạc'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: RoundedSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: Row(
                            children: [
                              SizedBox.square(
                                dimension: 34,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: context.tokens.surfaceHigh,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    Icons.volume_up_rounded,
                                    size: 19,
                                    color: context.tokens.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Âm lượng ứng dụng',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${(playerController.player.volume * 100).round()}%',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                          child: Slider(
                            value: playerController.player.volume,
                            onChanged: playerController.setVolume,
                          ),
                        ),
                        const GroupDivider(),
                        SettingsRow(
                          icon: Icons.timer_outlined,
                          title: 'Hẹn giờ tắt nhạc',
                          subtitle: _sleepTimerLabel(playerController.sleepEndsAt),
                          onTap: () => _selectSleepTimer(context),
                        ),
                        const GroupDivider(),
                        SettingsRow(
                          icon: Icons.lock_clock_outlined,
                          title: 'Phát nền và màn hình khóa',
                          subtitle: 'Đã bật sẵn',
                          trailing: Icon(
                            Icons.check_circle_rounded,
                            color: context.tokens.success,
                          ),
                        ),
                        const GroupDivider(),
                        SettingsRow(
                          icon: Icons.equalizer_rounded,
                          title: 'Thông tin âm thanh',
                          subtitle: 'Bitrate, sample rate và khả năng phát',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => QualityScreen(
                                libraryService: libraryService,
                                playerController: playerController,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Thư viện'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: RoundedSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingsRow(
                          icon: Icons.add_rounded,
                          title: 'Nhập thêm nhạc',
                          subtitle: 'Chọn file âm thanh từ ứng dụng Files',
                          enabled: !libraryService.isImporting,
                          onTap: () => showImportMusicSheet(
                            context: context,
                            libraryService: libraryService,
                          ),
                        ),
                        const GroupDivider(),
                        FutureBuilder<int>(
                          future: libraryService.storageBytes(),
                          builder: (context, snapshot) {
                            return SettingsRow(
                              icon: Icons.storage_rounded,
                              title: 'Bộ nhớ đang dùng',
                              subtitle:
                                  '${libraryService.songs.length} bài hát',
                              trailing: Text(
                                formatBytes(snapshot.data ?? 0),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          },
                        ),
                        const GroupDivider(),
                        SettingsRow(
                          icon: Icons.delete_outline_rounded,
                          title: 'Xóa toàn bộ thư viện',
                          subtitle: 'Xóa nhạc, ảnh bìa và playlist trong app',
                          destructive: true,
                          enabled: libraryService.songs.isNotEmpty,
                          onTap: () => _clearLibrary(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Ứng dụng'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverToBoxAdapter(
                  child: RoundedSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        const SettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: 'Offline Music',
                          subtitle: 'Dark Rounded Premium V14',
                          trailing: Text('14.0.0'),
                        ),
                        const GroupDivider(),
                        const SettingsRow(
                          icon: Icons.shield_outlined,
                          title: 'Quyền riêng tư',
                          subtitle: 'Không gửi thư viện nhạc lên máy chủ',
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

  Future<void> _selectTheme(BuildContext context) async {
    final selected = await showAppSelectionSheet<AppThemeChoice>(
      context: context,
      title: 'Chế độ hiển thị',
      selectedValue: preferences.themeChoice,
      options: const [
        AppSelectionOption(
          value: AppThemeChoice.system,
          title: 'Theo hệ thống',
          subtitle: 'Tự đổi theo cài đặt iPhone',
          icon: Icons.brightness_auto_rounded,
        ),
        AppSelectionOption(
          value: AppThemeChoice.light,
          title: 'Sáng',
          icon: Icons.light_mode_rounded,
        ),
        AppSelectionOption(
          value: AppThemeChoice.dark,
          title: 'Tối',
          icon: Icons.dark_mode_rounded,
        ),
      ],
    );
    if (selected != null) await preferences.setThemeChoice(selected);
  }

  Future<void> _selectSleepTimer(BuildContext context) async {
    final selected = await showAppSelectionSheet<int>(
      context: context,
      title: 'Hẹn giờ tắt nhạc',
      options: const [
        AppSelectionOption(value: 10, title: '10 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 20, title: '20 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 30, title: '30 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 45, title: '45 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 60, title: '60 phút', icon: Icons.timer_outlined),
        AppSelectionOption(value: 0, title: 'Tắt hẹn giờ', icon: Icons.timer_off_outlined),
      ],
    );
    if (selected == null) return;
    playerController.setSleepTimer(
      selected == 0 ? null : Duration(minutes: selected),
    );
  }

  Future<void> _clearLibrary(BuildContext context) async {
    final confirmed = await showAppConfirmation(
      context: context,
      title: 'Xóa toàn bộ thư viện?',
      message:
          'Tất cả file nhạc, ảnh bìa và playlist trong ứng dụng sẽ bị xóa. Thao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
      destructive: true,
    );
    if (!confirmed) return;
    await playerController.setQueue(const []);
    await libraryService.clearLibrary();
  }

  static String _themeLabel(AppThemeChoice choice) {
    return switch (choice) {
      AppThemeChoice.system => 'Theo hệ thống',
      AppThemeChoice.light => 'Chế độ sáng',
      AppThemeChoice.dark => 'Chế độ tối',
    };
  }

  static String _sleepTimerLabel(DateTime? end) {
    if (end == null) return 'Đang tắt';
    final minutes = end.difference(DateTime.now()).inMinutes + 1;
    return minutes > 0 ? 'Còn khoảng $minutes phút' : 'Sắp tắt';
  }
}
