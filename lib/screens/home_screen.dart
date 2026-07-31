import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../services/wifi_transfer_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import 'song_collection_screen.dart';
import 'wifi_transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
    required this.wifiTransferService,
    required this.onNavigate,
  });

  final LibraryService libraryService;
  final PlayerController playerController;
  final WifiTransferService wifiTransferService;
  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.libraryService, widget.playerController]),
        builder: (context, _) {
          final library = widget.libraryService;
          final searchResults = library.search(query);
          final recent = library.recentlyPlayed.take(8).toList();
          final mix = library.dailyMix.take(8).toList();
          final favorites = library.favorites.take(8).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Dành cho bạn',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.8,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onNavigate(3),
                        icon: const Icon(Icons.settings_outlined, size: 29),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      hintText: 'Tìm bài hát, nghệ sĩ, album...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              if (query.trim().isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final song = searchResults[index];
                      return SongTile(
                        song: song,
                        onTap: () => widget.playerController.playSong(searchResults, song),
                        onMore: () => showSongActions(
                          context,
                          song: song,
                          libraryService: library,
                        ),
                      );
                    },
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.history_rounded,
                            label: 'Lịch sử nghe',
                            onTap: () => _openCollection(
                              context,
                              'Lịch sử nghe',
                              library.recentlyPlayed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.wifi_tethering_rounded,
                            label: 'Truyền nhạc\nqua Wi‑Fi',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => WifiTransferScreen(
                                  service: widget.wifiTransferService,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.graphic_eq_rounded,
                            label: 'Âm lượng\n& hẹn giờ',
                            onTap: () => _showAudioTools(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 4),
                    child: InkWell(
                      onTap: () => widget.onNavigate(2),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF07110F), size: 34),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thư viện của bạn',
                                    style: TextStyle(
                                      color: Color(0xFF07110F),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${library.songs.length} bài • ${library.favoriteCount} yêu thích • ${compactCount(library.totalPlayCount)} lượt nghe',
                                    style: const TextStyle(
                                      color: Color(0xCC07110F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF07110F), size: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (library.songs.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyHome(
                      importing: library.isImporting,
                      onImport: () async {
                        final result = await library.importFromFiles();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        }
                      },
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _HorizontalSection(
                      title: 'Mix hằng ngày',
                      songs: mix,
                      libraryService: library,
                      playerController: widget.playerController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _HorizontalSection(
                      title: recent.isEmpty ? 'Mới thêm' : 'Nghe gần đây',
                      songs: recent.isEmpty ? library.songs.take(8).toList() : recent,
                      libraryService: library,
                      playerController: widget.playerController,
                    ),
                  ),
                  if (favorites.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: 'Bài hát yêu thích',
                        songs: favorites,
                        libraryService: library,
                        playerController: widget.playerController,
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openCollection(BuildContext context, String title, List<Song> songs) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SongCollectionScreen(
          title: title,
          songs: songs,
          libraryService: widget.libraryService,
          playerController: widget.playerController,
        ),
      ),
    );
  }

  Future<void> _showAudioTools(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: widget.playerController,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Âm lượng & hẹn giờ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.volume_down_rounded),
                  Expanded(
                    child: Slider(
                      value: widget.playerController.player.volume,
                      onChanged: widget.playerController.setVolume,
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded),
                ],
              ),
              const Divider(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in [10, 20, 30, 45, 60])
                    ActionChip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text('$minutes phút'),
                      onPressed: () {
                        widget.playerController.setSleepTimer(Duration(minutes: minutes));
                        Navigator.pop(context);
                      },
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.timer_off_outlined, size: 18),
                    label: const Text('Tắt hẹn giờ'),
                    onPressed: () {
                      widget.playerController.setSleepTimer(null);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Bộ cân bằng EQ và bit-perfect cần audio engine native riêng; bản này không giả lập hai chức năng đó.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 118,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E2021),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accent, size: 30),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(color: AppColors.muted, height: 1.25, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.songs,
    required this.libraryService,
    required this.playerController,
  });

  final String title;
  final List<Song> songs;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => playerController.playAll(songs),
                      icon: const Icon(Icons.play_arrow_rounded, size: 19),
                      label: const Text('Phát tất cả'),
                    ),
                    TextButton.icon(
                      onPressed: () => playerController.playAll(songs, shuffle: true),
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: const Text('Phát ngẫu nhiên'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 215,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              scrollDirection: Axis.horizontal,
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final song = songs[index];
                return SizedBox(
                  width: 142,
                  child: InkWell(
                    onTap: () => playerController.playSong(songs, song),
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SongArtwork(song: song, size: 142, borderRadius: 16),
                        const SizedBox(height: 9),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.importing, required this.onImport});
  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 10),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.library_music_outlined, size: 56, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text('Thư viện đang trống', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text(
              'Nhập file nhạc từ ứng dụng Files hoặc truyền từ máy tính qua Wi‑Fi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: importing ? null : onImport,
              icon: importing
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_rounded),
              label: const Text('Nhập nhạc từ Files'),
            ),
          ],
        ),
      ),
    );
  }
}
