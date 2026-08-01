import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import '../widgets/studio_widgets.dart';
import 'now_playing_screen.dart';
import 'song_collection_screen.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AppPage(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          libraryService,
          playerController,
        ]),
        builder: (context, _) {
          final songs = libraryService.songs;
          final recents = libraryService.recentlyPlayed.take(8).toList();
          final favorites = libraryService.favorites.take(8).toList();
          final mostPlayed = libraryService.dailyMix.take(6).toList();
          final albums = libraryService.byAlbum.entries.take(8).toList();

          return CustomScrollView(
            key: const PageStorageKey<String>('home-page'),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: _greeting(),
                  title: 'Dành cho bạn',
                  subtitle: songs.isEmpty
                      ? 'Thêm nhạc để bắt đầu thư viện cá nhân.'
                      : '${songs.length} bài hát • nghe hoàn toàn offline',
                  actions: [
                    CircleIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: 'Cài đặt',
                      onPressed: () => onNavigate(3),
                    ),
                  ],
                ),
              ),
              if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.library_music_rounded,
                    title: 'Thư viện đang trống',
                    message:
                        'Nhập file nhạc từ ứng dụng Files để nghe offline.',
                    action: PrimaryButton(
                      label: 'Thêm nhạc',
                      icon: Icons.add_rounded,
                      expanded: false,
                      onPressed: libraryService.isImporting
                          ? null
                          : () => showImportMusicSheet(
                                context: context,
                                libraryService: libraryService,
                              ),
                    ),
                  ),
                )
              else ...[
                if (playerController.currentSong != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    sliver: SliverToBoxAdapter(
                      child: _ContinueCard(
                        song: playerController.currentSong!,
                        libraryService: libraryService,
                        playerController: playerController,
                      ),
                    ),
                  ),
                SectionHeaderSliver(
                  title: 'Nghe gần đây',
                  subtitle: recents.isEmpty
                      ? 'Các bài đã phát sẽ xuất hiện ở đây'
                      : '${recents.length} bài gần nhất',
                  onViewAll: recents.isEmpty
                      ? null
                      : () => _openCollection(
                            context,
                            'Nghe gần đây',
                            recents,
                          ),
                ),
                if (recents.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        icon: Icons.history_rounded,
                        title: 'Chưa có lịch sử nghe',
                        message: 'Phát một bài hát để bắt đầu.',
                        compact: true,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 205,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: recents.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final song = recents[index];
                          return _MusicCard(
                            song: song,
                            onTap: () => playerController.playSong(recents, song),
                          );
                        },
                      ),
                    ),
                  ),
                SectionHeaderSliver(
                  title: 'Album gần đây',
                  subtitle: '${albums.length} album trong thư viện',
                ),
                if (albums.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 210,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final entry = albums[index];
                          return _AlbumCard(
                            name: entry.key,
                            songs: entry.value,
                            onTap: () => _openCollection(
                              context,
                              entry.key,
                              entry.value,
                              subtitle: '${entry.value.length} bài hát',
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (favorites.isNotEmpty) ...[
                  SectionHeaderSliver(
                    title: 'Yêu thích',
                    subtitle: '${libraryService.favoriteCount} bài hát',
                    onViewAll: () => _openCollection(
                      context,
                      'Yêu thích',
                      libraryService.favorites,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 68),
                      itemBuilder: (context, index) => SongTile(
                        song: favorites[index],
                        source: libraryService.favorites,
                        libraryService: libraryService,
                        playerController: playerController,
                      ),
                    ),
                  ),
                ],
                SectionHeaderSliver(
                  title: 'Nghe nhiều',
                  subtitle: 'Dựa trên lịch sử phát của bạn',
                  onViewAll: () => _openCollection(
                    context,
                    'Nghe nhiều',
                    libraryService.dailyMix,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: mostPlayed.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 68),
                    itemBuilder: (context, index) => SongTile(
                      song: mostPlayed[index],
                      source: libraryService.dailyMix,
                      libraryService: libraryService,
                      playerController: playerController,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  void _openCollection(
    BuildContext context,
    String title,
    List<Song> songs, {
    String? subtitle,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SongCollectionScreen(
          title: title,
          subtitle: subtitle ?? '${songs.length} bài hát',
          songs: songs,
          libraryService: libraryService,
          playerController: playerController,
        ),
      ),
    );
  }
}

class SectionHeaderSliver extends StatelessWidget {
  const SectionHeaderSliver({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SectionHeader(
        title: title,
        subtitle: subtitle,
        trailing: onViewAll == null
            ? null
            : TextButton(
                onPressed: onViewAll,
                child: const Text('Xem tất cả'),
              ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.song,
    required this.libraryService,
    required this.playerController,
  });

  final Song song;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return RoundedSurface(
      radius: 26,
      color: context.tokens.surfaceHigh,
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NowPlayingScreen(
            libraryService: libraryService,
            playerController: playerController,
          ),
        ),
      ),
      child: Row(
        children: [
          SongArtwork(
            song: song,
            size: 78,
            borderRadius: 20,
            showBorder: false,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIẾP TỤC NGHE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: playerController.player.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            selected: true,
            tooltip: 'Phát hoặc tạm dừng',
            onPressed: playerController.playOrPause,
          ),
        ],
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SongArtwork(
              song: song,
              size: 150,
              borderRadius: 22,
              showBorder: false,
            ),
            const SizedBox(height: 9),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.name,
    required this.songs,
    required this.onTap,
  });

  final String name;
  final List<Song> songs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artworkSong = songs.first;
    return SizedBox(
      width: 150,
      child: PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SongArtwork(
              song: artworkSong,
              size: 150,
              borderRadius: 22,
              showBorder: false,
            ),
            const SizedBox(height: 9),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              '${songs.length} bài hát',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
