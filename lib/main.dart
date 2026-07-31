import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/quality_screen.dart';
import 'screens/settings_screen.dart';
import 'services/library_service.dart';
import 'services/player_controller.dart';
import 'utils/app_theme.dart';
import 'widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ducmanhit.offlinemusic.audio',
    androidNotificationChannelName: 'Offline Music',
    androidNotificationOngoing: true,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const OfflineMusicApp());
}

class OfflineMusicApp extends StatefulWidget {
  const OfflineMusicApp({super.key});

  @override
  State<OfflineMusicApp> createState() => _OfflineMusicAppState();
}

class _OfflineMusicAppState extends State<OfflineMusicApp> {
  late final LibraryService libraryService;
  late final PlayerController playerController;
  bool ready = false;
  String? error;

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
      setState(() => error = exception.toString());
    }
  }

  @override
  void dispose() {
    playerController.dispose();
    libraryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Music',
      theme: buildLightTheme(),
      home: error != null
          ? _StartupError(message: error!)
          : ready
              ? HomeShell(
                  libraryService: libraryService,
                  playerController: playerController,
                )
              : const Scaffold(
                  body: AppBackdrop(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 14),
                    ),
                  ),
                ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  void navigate(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
        onNavigate: navigate,
      ),
      QualityScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
      LibraryScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
      SettingsScreen(
        libraryService: widget.libraryService,
        playerController: widget.playerController,
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MiniPlayer(
              libraryService: widget.libraryService,
              playerController: widget.playerController,
            ),
            const SizedBox(height: 7),
            _LiquidTabBar(index: index, onChanged: navigate),
          ],
        ),
      ),
    );
  }
}

class _LiquidTabBar extends StatelessWidget {
  const _LiquidTabBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const items = [
    (CupertinoIcons.music_note_2, 'Trang chủ'),
    (CupertinoIcons.waveform, 'Âm thanh'),
    (CupertinoIcons.music_albums, 'Thư viện'),
    (CupertinoIcons.gear_alt, 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 34,
      blur: 38,
      opacity: .075,
      shadow: true,
      highlight: true,
      pressable: false,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 61,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * index + 2,
                  top: 1,
                  width: itemWidth - 4,
                  height: 55,
                  child: const LiquidLens(
                    borderRadius: 28,
                    blur: 34,
                    opacity: .19,
                    shadow: false,
                    child: SizedBox.expand(),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _LiquidTabItem(
                          icon: items[i].$1,
                          label: items[i].$2,
                          selected: i == index,
                          onTap: () => onChanged(i),
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
}

class _LiquidTabItem extends StatelessWidget {
  const _LiquidTabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          color: selected ? AppColors.accent : AppColors.graphiteSoft,
          fontFamily: '.SF Pro Text',
          fontSize: 10.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -.15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: selected ? 1.055 : 1,
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.accent : AppColors.graphiteSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1),
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
    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle, size: 52),
                const SizedBox(height: 20),
                const Text(
                  'Không thể mở ứng dụng',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
