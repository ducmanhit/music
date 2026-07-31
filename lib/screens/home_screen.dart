import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import 'song_collection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
    required this.onNavigate,
  });

  final LibraryService libraryService;
  final PlayerController playerController;
  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: widget.libraryService,
          builder: (context, _) {
            final library = widget.libraryService;
            final searchResults = library.search(query);
            final recent = library.recentlyPlayed.take(8).toList();
            final mix = library.dailyMix.take(8).toList();
            final favorites = library.favorites.take(8).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offline Music',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Dành cho bạn',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GlassIconButton(
                          icon: Icons.settings_outlined,
                          tooltip: 'Cài đặt',
                          onPressed: () => widget.onNavigate(3),
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
                        hintText: 'Tìm bài hát, nghệ sĩ, album',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                ),
                if (query.trim().isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 150),
                    sliver: searchResults.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text(
                                  'Không tìm thấy bài hát phù hợp',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ),
                            ),
                          )
                        : SliverList.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final song = searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .48),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: SongTile(
                                    song: song,
                                    onTap: () => widget.playerController
                                        .playSong(searchResults, song),
                                    onMore: () => showSongActions(
                                      context,
                                      song: song,
                                      libraryService: library,
                                      playerController: widget.playerController,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _LibraryHero(
                        library: library,
                        onTap: () => widget.onNavigate(2),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickCard(
                              icon: Icons.history_rounded,
                              label: 'Lịch sử',
                              subtitle: 'Bài đã nghe gần đây',
                              onTap: () => _openCollection(
                                context,
                                'Lịch sử nghe',
                                library.recentlyPlayed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickCard(
                              icon: Icons.timer_outlined,
                              label: 'Hẹn giờ',
                              subtitle: 'Âm lượng và tắt nhạc',
                              onTap: () => _showAudioTools(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickCard(
                              icon: Icons.add_rounded,
                              label: 'Thêm nhạc',
                              subtitle: 'Nhập file từ Files',
                              onTap: () => showImportMusicSheet(
                                context,
                                libraryService: library,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (library.songs.isEmpty)
                    SliverToBoxAdapter(
                      child: _EmptyHome(
                        importing: library.isImporting,
                        onImport: () => showImportMusicSheet(
                          context,
                          libraryService: library,
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: 'Mix hằng ngày',
                        subtitle: 'Gợi ý từ thư viện của bạn',
                        songs: mix,
                        libraryService: library,
                        playerController: widget.playerController,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: recent.isEmpty ? 'Mới thêm' : 'Nghe gần đây',
                        subtitle: recent.isEmpty
                            ? 'Những bài vừa được đưa vào app'
                            : 'Tiếp tục nơi bạn đã dừng',
                        songs: recent.isEmpty
                            ? library.songs.take(8).toList()
                            : recent,
                        libraryService: library,
                        playerController: widget.playerController,
                      ),
                    ),
                    if (favorites.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _HorizontalSection(
                          title: 'Yêu thích',
                          subtitle: 'Những bài bạn đã đánh dấu',
                          songs: favorites,
                          libraryService: library,
                          playerController: widget.playerController,
                        ),
                      ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 160)),
                ],
              ],
            );
          },
        ),
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
              const Text(
                'Âm lượng & hẹn giờ',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                blur: 10,
                opacity: .24,
                shadow: false,
                child: Row(
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
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in [10, 20, 30, 45, 60])
                    ActionChip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text('$minutes phút'),
                      onPressed: () {
                        widget.playerController
                            .setSleepTimer(Duration(minutes: minutes));
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryHero extends StatelessWidget {
  const _LibraryHero({required this.library, required this.onTap});

  final LibraryService library;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      borderRadius: 30,
      blur: 34,
      opacity: .58,
      tint: AppColors.graphite,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        height: 112,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Thư viện của bạn',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${library.songs.length} bài hát  •  ${library.favoriteCount} yêu thích',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${compactCount(library.totalPlayCount)} lượt nghe',
                    style: const TextStyle(
                      color: AppColors.mutedSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox.square(
              dimension: 62,
              child: GlassPanel(
                borderRadius: 21,
                blur: 22,
                opacity: .72,
                shadow: false,
                tint: AppColors.graphite,
                child: const Center(
                  child: Icon(
                    Icons.library_music_rounded,
                    color: AppColors.graphite,
                    size: 29,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
      borderRadius: 21,
      blur: 14,
      opacity: .20,
      onTap: onTap,
      child: SizedBox(
        height: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0x19787880),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.graphite, size: 21),
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
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
    required this.subtitle,
    required this.songs,
    required this.libraryService,
    required this.playerController,
  });

  final String title;
  final String subtitle;
  final List<Song> songs;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.35,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Phát ngẫu nhiên',
                  onPressed: () => playerController.playAll(songs, shuffle: true),
                  icon: const Icon(Icons.shuffle_rounded),
                ),
                IconButton(
                  tooltip: 'Phát tất cả',
                  onPressed: () => playerController.playAll(songs),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 216,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              scrollDirection: Axis.horizontal,
              itemCount: songs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final song = songs[index];
                return SizedBox(
                  width: 145,
                  child: InkWell(
                    onTap: () => playerController.playSong(songs, song),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x24172B4D),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SongArtwork(
                            song: song,
                            size: 145,
                            borderRadius: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
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
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
      child: GlassPanel(
        padding: const EdgeInsets.all(28),
        borderRadius: 26,
        blur: 18,
        opacity: .22,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bắt đầu thư viện của bạn',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập nhạc từ ứng dụng Files để nghe offline, không quảng cáo và không cần tài khoản.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: importing ? null : onImport,
              icon: importing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: const Text('Chọn file nhạc'),
            ),
          ],
        ),
      ),
    );
  }
}
