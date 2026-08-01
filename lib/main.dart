import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/quality_screen.dart';
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
  Object? error;

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
    } catch (exception) {
      if (!mounted) return;
      setState(() => error = exception);
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
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline Music',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: widget.preferences.themeMode,
        builder: (context, child) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          final style = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: context.tokens.canvas,
            systemNavigationBarIconBrightness:
                dark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          );
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: style,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: error != null
            ? _StartupError(message: error.toString())
            : ready
                ? HomeShell(
                    preferences: widget.preferences,
                    libraryService: libraryService,
                    playerController: playerController,
                  )
                : const _StartupLoading(),
      ),
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
  int index = 0;

  void navigate(int value) {
    if (value == index) return;
    setState(() => index = value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
        onNavigate: navigate,
      ),
      LibraryScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
      QualityScreen(
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
      backgroundColor: context.tokens.canvas,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiniPlayer(
                libraryService: widget.libraryService,
                playerController: widget.playerController,
              ),
              const SizedBox(height: 10),
              _RoundedDock(
                selectedIndex: index,
                onSelected: navigate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedDock extends StatelessWidget {
  const _RoundedDock({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = <({IconData icon, IconData activeIcon, String label})>[
      (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Trang chủ'),
      (icon: Icons.library_music_outlined, activeIcon: Icons.library_music_rounded, label: 'Thư viện'),
      (icon: Icons.graphic_eq_outlined, activeIcon: Icons.graphic_eq_rounded, label: 'Âm thanh'),
      (icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Cài đặt'),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.tokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.tokens.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _DockItem(
                icon: items[i].icon,
                activeIcon: items[i].activeIcon,
                label: items[i].label,
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected ? context.tokens.surfaceStrong : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected
                    ? (dark ? Colors.white : const Color(0xFF17181C))
                    : context.tokens.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? (dark ? Colors.white : const Color(0xFF17181C))
                      : context.tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      safeBottom: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang chuẩn bị thư viện nhạc...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56),
              const SizedBox(height: 12),
              Text(
                'Không thể khởi tạo ứng dụng',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
