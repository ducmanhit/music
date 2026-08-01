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
            systemNavigationBarColor: context.tokens.surface,
            systemNavigationBarIconBrightness:
                dark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: context.tokens.border,
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
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.tokens.surface,
          border: Border(top: BorderSide(color: context.tokens.border)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiniPlayer(
                libraryService: widget.libraryService,
                playerController: widget.playerController,
              ),
              NavigationBar(
                selectedIndex: index,
                onDestinationSelected: navigate,
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.library_music_outlined),
                    selectedIcon: Icon(Icons.library_music_rounded),
                    label: 'Thư viện',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.graphic_eq_outlined),
                    selectedIcon: Icon(Icons.graphic_eq_rounded),
                    label: 'Âm thanh',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: 'Cài đặt',
                  ),
                ],
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
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 18),
            Text('Đang mở thư viện…', style: Theme.of(context).textTheme.titleMedium),
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
      safeBottom: true,
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Không thể mở ứng dụng',
        message: message,
      ),
    );
  }
}
