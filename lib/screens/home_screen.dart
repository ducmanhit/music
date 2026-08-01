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
        animation: Listenable.merge(<Listenable>[libraryService, playerController]),
        builder: (context, _) {
          final songs = libraryService.songs;
          final recent = libraryService.recentlyPlayed.take(6).toList();
          final featured = libraryService.dailyMix.take(8).toList();
          return CustomScrollView(
            key: const PageStorageKey<String>('home-scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: 'Offline Music Studio',
                  title: 'Nhạc của bạn',
                  subtitle: songs.isEmpty
                      ? 'Thêm file âm thanh để bắt đầu.'
                      : '${songs.length} bài hát · ${libraryService.playlists.length} playlist',
                  actions: [
                    FlatIconButton(
                      icon: Icons.add_rounded,
                      selected: true,
                      tooltip: 'Thêm nhạc',
                      onPressed: libraryService.isImporting
                          ? null
                          : () => showImportMusicSheet(
                                context: context,
                                libraryService: libraryService,
                              ),
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
                    message: 'Chọn file MP3, M4A, AAC, WAV hoặc FLAC từ ứng dụng Files. Nhạc được lưu trong app để nghe offline.',
                    actionLabel: 'Chọn nhạc',
                    onAction: () => showImportMusicSheet(
                      context: context,
                      libraryService: libraryService,
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: SizedBox(
                      height: 132,
                      child: Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Bài hát',
                              value: '${songs.length}',
                              icon: Icons.music_note_rounded,
                              onTap: () => onNavigate(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              label: 'Yêu thích',
                              value: '${libraryService.favoriteCount}',
                              icon: Icons.favorite_rounded,
                              onTap: () => _openCollection(
                                context,
                                'Yêu thích',
                                libraryService.favorites,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              label: 'Playlist',
                              value: '${libraryService.playlists.length}',
                              icon: Icons.queue_music_rounded,
                              onTap: () => onNavigate(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _QuickActions(
                    onPlayAll: () => playerController.playAll(songs),
                    onShuffle: () => playerController.playAll(songs, shuffle: true),
                    onFavorites: () => _openCollection(
                      context,
                      'Yêu thích',
                      libraryService.favorites,
                    ),
                    onLibrary: () => onNavigate(1),
                  ),
                ),
                if (playerController.currentSong != null)
                  SliverToBoxAdapter(
                    child: _ContinueCard(
                      song: playerController.currentSong!,
                      playerController: playerController,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NowPlayingScreen(
                            libraryService: libraryService,
                            playerController: playerController,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (featured.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Gợi ý từ thư viện',
                      subtitle: 'Dựa trên bài đã nghe và bài mới thêm',
                      actionLabel: 'Phát tất cả',
                      onAction: () => playerController.playAll(featured),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 190,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final song = featured[index];
                          return _FeaturedSongCard(
                            song: song,
                            onTap: () => playerController.playSong(featured, song),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: recent.isEmpty ? 'Mới thêm' : 'Nghe gần đây',
                    actionLabel: 'Xem thư viện',
                    onAction: () => onNavigate(1),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final source = recent.isEmpty ? songs.take(6).toList() : recent;
                        final song = source[index];
                        return SongTile(
                          song: song,
                          selected: playerController.currentSong?.id == song.id,
                          onTap: () => playerController.playSong(source, song),
                          onMore: () => showSongActions(
                            context,
                            song: song,
                            libraryService: libraryService,
                            playerController: playerController,
                          ),
                        );
                      },
                      childCount: (recent.isEmpty ? songs.take(6) : recent).length,
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

  void _openCollection(BuildContext context, String title, List<Song> songs) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SongCollectionScreen(
          title: title,
          songs: songs,
          libraryService: libraryService,
          playerController: playerController,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onPlayAll,
    required this.onShuffle,
    required this.onFavorites,
    required this.onLibrary,
  });

  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;
  final VoidCallback onFavorites;
  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.play_arrow_rounded, label: 'Phát tất cả', onTap: onPlayAll),
      (icon: Icons.shuffle_rounded, label: 'Ngẫu nhiên', onTap: onShuffle),
      (icon: Icons.favorite_border_rounded, label: 'Yêu thích', onTap: onFavorites),
      (icon: Icons.folder_copy_outlined, label: 'Thư viện', onTap: onLibrary),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: SurfaceCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              Expanded(
                child: InkWell(
                  onTap: actions[index].onTap,
                  borderRadius: BorderRadius.circular(13),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          actions[index].icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          actions[index].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (index < actions.length - 1)
                SizedBox(
                  height: 38,
                  child: VerticalDivider(color: context.tokens.border),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.song,
    required this.playerController,
    required this.onOpen,
  });

  final Song song;
  final PlayerController playerController;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: SurfaceCard(
        padding: const EdgeInsets.all(14),
        onTap: onOpen,
        color: context.tokens.accentSoft,
        child: Row(
          children: [
            SongArtwork(song: song, size: 72, borderRadius: 16),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐANG PHÁT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: playerController.playOrPause,
              icon: Icon(
                playerController.player.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSongCard extends StatelessWidget {
  const _FeaturedSongCard({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SongArtwork(song: song, size: 134, borderRadius: 16),
              const SizedBox(height: 9),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
