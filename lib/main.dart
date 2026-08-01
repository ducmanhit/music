import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_preferences.dart';
import 'services/library_service.dart';
import 'services/player_controller.dart';
import 'utils/app_theme.dart';
import 'widgets/mini_player.dart';
import 'widgets/studio_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ducmanhit.offlinemusic.audio',
    androidNotificationChannelName: 'Offline Music',
    androidNotificationOngoing: true,
  );
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final preferences = AppPreferences();
  await preferences.initialize();
  runApp(OfflineMusicApp(preferences: preferences));
}

class OfflineMusicApp extends StatefulWidget {
  const OfflineMusicApp({super.key, required this.preferences});

  final AppPreferences preferences;

  @override
  State<OfflineMusicApp> createState() => _OfflineMusicAppState();
}

class _OfflineMusicAppState extends State<OfflineMusicApp> {
  late final LibraryService libraryService;
  late final PlayerController playerController;
  bool ready = false;
  Object? startupError;

  @override
  void initState() {
    super.initState();
    libraryService = LibraryService();
    playerController = PlayerController(libraryService);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await libraryService.initialize();
      await playerController.initialize();
      if (!mounted) return;
      setState(() => ready = true);
    } catch (error) {
      if (!mounted) return;
      setState(() => startupError = error);
    }
  }

  @override
  void dispose() {
    playerController.dispose();
    libraryService.dispose();
    widget.preferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.preferences,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Offline Music',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: widget.preferences.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 220),
          themeAnimationCurve: Curves.easeOutCubic,
          builder: (context, child) {
            final dark = Theme.of(context).brightness == Brightness.dark;
            final style = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  dark ? Brightness.light : Brightness.dark,
              statusBarBrightness: dark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: context.tokens.background,
              systemNavigationBarIconBrightness:
                  dark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            );
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: style,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: startupError != null
              ? _StartupError(message: startupError.toString())
              : ready
                  ? HomeShell(
                      preferences: widget.preferences,
                      libraryService: libraryService,
                      playerController: playerController,
                    )
                  : const _StartupLoading(),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.preferences,
    required this.libraryService,
    required this.playerController,
  });

  final AppPreferences preferences;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;

  void _selectTab(int index) {
    if (index == selectedIndex) return;
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
        onNavigate: _selectTab,
      ),
      SearchScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
      LibraryScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
      SettingsScreen(
        preferences: widget.preferences,
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
    ];

    return Scaffold(
      backgroundColor: context.tokens.background,
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MiniPlayer(
                libraryService: widget.libraryService,
                playerController: widget.playerController,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AppBottomNavigation(
                selectedIndex: selectedIndex,
                onSelected: _selectTab,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBottomNavigation extends StatelessWidget {
  const _AppBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <({IconData icon, IconData active, String label})>[
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Trang chủ'),
    (icon: Icons.search_rounded, active: Icons.search_rounded, label: 'Tìm kiếm'),
    (
      icon: Icons.library_music_outlined,
      active: Icons.library_music_rounded,
      label: 'Thư viện',
    ),
    (
      icon: Icons.settings_outlined,
      active: Icons.settings_rounded,
      label: 'Cài đặt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.tokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.tokens.border),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _items.length; index++)
            Expanded(
              child: _NavigationItem(
                item: _items[index],
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ({IconData icon, IconData active, String label}) item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? context.tokens.surfaceHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.active : item.icon,
              size: 22,
              color: selected
                  ? context.tokens.textPrimary
                  : context.tokens.textTertiary,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? context.tokens.textPrimary
                        : context.tokens.textTertiary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SafeArea(
        child: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Không thể khởi động ứng dụng',
          message: message,
        ),
      ),
    );
  }
}
