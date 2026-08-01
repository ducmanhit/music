import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/app_modal.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import '../widgets/studio_widgets.dart';

class SongCollectionScreen extends StatefulWidget {
  const SongCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songs,
    required this.libraryService,
    required this.playerController,
    this.playlist,
  });

  final String title;
  final String subtitle;
  final List<Song> songs;
  final MusicPlaylist? playlist;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<SongCollectionScreen> createState() => _SongCollectionScreenState();
}

class _SongCollectionScreenState extends State<SongCollectionScreen> {
  String query = '';

  List<Song> get visibleSongs {
    return widget.libraryService.search(query, source: widget.songs);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.libraryService,
        widget.playerController,
      ]),
      builder: (context, _) {
        final currentSongs = widget.playlist == null
            ? widget.songs
            : widget.libraryService.songsForPlaylist(widget.playlist!);
        final songs = widget.libraryService.search(query, source: currentSongs);
        final artworkSong = songs.isNotEmpty
            ? songs.first
            : currentSongs.isNotEmpty
                ? currentSongs.first
                : null;

        return Scaffold(
          backgroundColor: context.tokens.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            actions: [
              if (widget.playlist != null)
                IconButton(
                  onPressed: _showPlaylistMenu,
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: MiniPlayer(
              libraryService: widget.libraryService,
              playerController: widget.playerController,
            ),
          ),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _CollectionHeader(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      artworkSong: artworkSong,
                      songs: currentSongs,
                      playerController: widget.playerController,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  sliver: SliverToBoxAdapter(
                    child: AppSearchField(
                      hintText: 'Tìm trong bộ sưu tập',
                      onChanged: (value) => setState(() => query = value),
                    ),
                  ),
                ),
                if (songs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.music_off_rounded,
                      title: 'Không có bài hát',
                      message: 'Bộ sưu tập này chưa có bài hát phù hợp.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverList.separated(
                      itemCount: songs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 98),
                      itemBuilder: (context, index) => SongTile(
                        song: songs[index],
                        source: songs,
                        showIndex: index + 1,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlaylistMenu() async {
    final playlist = widget.playlist;
    if (playlist == null) return;
    final action = await showAppSelectionSheet<String>(
      context: context,
      title: playlist.name,
      options: const [
        AppSelectionOption(
          value: 'rename',
          title: 'Đổi tên playlist',
          icon: Icons.edit_rounded,
        ),
        AppSelectionOption(
          value: 'delete',
          title: 'Xóa playlist',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (action == null || !mounted) return;
    if (action == 'rename') {
      final name = await showAppTextPrompt(
        context: context,
        title: 'Đổi tên playlist',
        initialValue: playlist.name,
        placeholder: 'Tên playlist',
      );
      if (name != null) {
        await widget.libraryService.renamePlaylist(playlist.id, name);
      }
      return;
    }

    final confirmed = await showAppConfirmation(
      context: context,
      title: 'Xóa playlist?',
      message: 'Các bài hát vẫn được giữ trong thư viện.',
      confirmLabel: 'Xóa',
      destructive: true,
    );
    if (!confirmed) return;
    await widget.libraryService.deletePlaylist(playlist.id);
    if (mounted) Navigator.pop(context);
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.title,
    required this.subtitle,
    required this.artworkSong,
    required this.songs,
    required this.playerController,
  });

  final String title;
  final String subtitle;
  final Song? artworkSong;
  final List<Song> songs;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (artworkSong != null)
              SongArtwork(
                song: artworkSong!,
                size: 128,
                borderRadius: 24,
                showBorder: false,
              )
            else
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: context.tokens.surfaceHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  size: 44,
                  color: context.tokens.textSecondary,
                ),
              ),
            const SizedBox(width: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BỘ SƯU TẬP',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Phát',
                icon: Icons.play_arrow_rounded,
                onPressed: songs.isEmpty
                    ? null
                    : () => playerController.playAll(songs),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton(
                label: 'Ngẫu nhiên',
                icon: Icons.shuffle_rounded,
                onPressed: songs.isEmpty
                    ? null
                    : () => playerController.playAll(songs, shuffle: true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
