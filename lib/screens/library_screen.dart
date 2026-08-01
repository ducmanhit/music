import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/app_modal.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import '../widgets/studio_widgets.dart';
import 'song_collection_screen.dart';

enum SongSort { title, artist, added, duration }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  SongSort sort = SongSort.title;

  List<Song> _sortedSongs() {
    final result = widget.libraryService.search(query);
    switch (sort) {
      case SongSort.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSort.artist:
        result.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case SongSort.added:
        result.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case SongSort.duration:
        result.sort((a, b) => b.durationMs.compareTo(a.durationMs));
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: DefaultTabController(
        length: 5,
        child: AnimatedBuilder(
          animation: widget.libraryService,
          builder: (context, _) {
            final songs = _sortedSongs();
            return Column(
              children: [
                PageHeader(
                  eyebrow: 'Bộ sưu tập',
                  title: 'Library',
                  subtitle: '${widget.libraryService.songs.length} bài hát trong bộ nhớ ứng dụng',
                  actions: [
                    FlatIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Làm mới',
                      onPressed: widget.libraryService.isImporting ? null : _rescan,
                    ),
                    FlatIconButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Thêm nhạc',
                      selected: true,
                      onPressed: widget.libraryService.isImporting
                          ? null
                          : () => showImportMusicSheet(
                                context: context,
                                libraryService: widget.libraryService,
                              ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => query = value),
                          decoration: const InputDecoration(
                            hintText: 'Tìm bài hát, nghệ sĩ, album',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FlatIconButton(
                        icon: Icons.sort_rounded,
                        tooltip: 'Sắp xếp',
                        onPressed: _selectSort,
                      ),
                    ],
                  ),
                ),
                if (widget.playerController.currentSong != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: SurfaceCard(
                      radius: 26,
                      color: context.tokens.surfaceMuted,
                      onTap: () => widget.playerController.playOrPause(),
                      child: Row(
                        children: [
                          SongArtwork(
                            song: widget.playerController.currentSong!,
                            size: 70,
                            borderRadius: 18,
                            showBorder: false,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currently Playing',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: context.tokens.textMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.playerController.currentSong!.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.playerController.currentSong!.artist,
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
                          FilledButton(
                            onPressed: widget.playerController.playOrPause,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(68, 46),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Icon(Icons.play_arrow_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Bài hát'),
                    Tab(text: 'Playlist'),
                    Tab(text: 'Thư mục'),
                    Tab(text: 'Nghệ sĩ'),
                    Tab(text: 'Album'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _SongsTab(
                        songs: songs,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _PlaylistsTab(
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _GroupsTab(
                        groups: widget.libraryService.byFolder,
                        emptyText: 'Chưa có thư mục nhạc',
                        icon: Icons.folder_outlined,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _GroupsTab(
                        groups: widget.libraryService.byArtist,
                        emptyText: 'Chưa có thông tin nghệ sĩ',
                        icon: Icons.person_outline_rounded,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _GroupsTab(
                        groups: widget.libraryService.byAlbum,
                        emptyText: 'Chưa có thông tin album',
                        icon: Icons.album_outlined,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectSort() async {
    final selected = await showAppSelectionSheet<SongSort>(
      context: context,
      title: 'Sắp xếp bài hát',
      selectedValue: sort,
      options: const [
        AppSelectionOption(
          value: SongSort.title,
          title: 'Tên bài hát',
          icon: Icons.sort_by_alpha_rounded,
        ),
        AppSelectionOption(
          value: SongSort.artist,
          title: 'Nghệ sĩ',
          icon: Icons.person_outline_rounded,
        ),
        AppSelectionOption(
          value: SongSort.added,
          title: 'Ngày thêm mới nhất',
          icon: Icons.schedule_rounded,
        ),
        AppSelectionOption(
          value: SongSort.duration,
          title: 'Thời lượng dài nhất',
          icon: Icons.timer_outlined,
        ),
      ],
    );
    if (selected != null && mounted) setState(() => sort = selected);
  }

  Future<void> _rescan() async {
    final result = await widget.libraryService.rescanMusicFolder();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _SongsTab extends StatelessWidget {
  const _SongsTab({
    required this.songs,
    required this.libraryService,
    required this.playerController,
  });

  final List<Song> songs;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const EmptyState(
        icon: Icons.music_off_rounded,
        title: 'Không có bài hát',
        message: 'Hãy thêm nhạc hoặc thử từ khóa tìm kiếm khác.',
        compact: true,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => playerController.playAll(songs),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Phát tất cả'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => playerController.playAll(songs, shuffle: true),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Ngẫu nhiên'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                selected: playerController.currentSong?.id == song.id,
                onTap: () => playerController.playSong(songs, song),
                onMore: () => showSongActions(
                  context,
                  song: song,
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab({
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final playlists = libraryService.playlists;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _createPlaylist(context),
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Tạo playlist'),
            ),
          ),
        ),
        Expanded(
          child: playlists.isEmpty
              ? const EmptyState(
                  icon: Icons.queue_music_rounded,
                  title: 'Chưa có playlist',
                  message: 'Tạo playlist để sắp xếp các bài hát theo sở thích.',
                  compact: true,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  itemCount: playlists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final songs = libraryService.songsForPlaylist(playlist);
                    return SurfaceCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PlaylistDetailScreen(
                            playlistId: playlist.id,
                            libraryService: libraryService,
                            playerController: playerController,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _PlaylistArtwork(songs: songs),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(playlist.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  '${songs.length} bài hát',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.tokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: context.tokens.textFaint),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final name = await showAppTextPrompt(
      context: context,
      title: 'Tạo playlist',
      placeholder: 'Tên playlist',
    );
    if (name != null) await libraryService.createPlaylist(name);
  }
}

class _PlaylistArtwork extends StatelessWidget {
  const _PlaylistArtwork({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: context.tokens.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.queue_music_rounded, color: context.tokens.textMuted),
      );
    }
    return SongArtwork(song: songs.first, size: 58, borderRadius: 14);
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.groups,
    required this.emptyText,
    required this.icon,
    required this.libraryService,
    required this.playerController,
  });

  final Map<String, List<Song>> groups;
  final String emptyText;
  final IconData icon;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final entries = groups.entries.toList();
    if (entries.isEmpty) {
      return EmptyState(
        icon: icon,
        title: emptyText,
        message: 'Thông tin sẽ xuất hiện sau khi bạn thêm file nhạc có metadata.',
        compact: true,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return SurfaceCard(
          padding: const EdgeInsets.all(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SongCollectionScreen(
                title: entry.key,
                songs: entry.value,
                libraryService: libraryService,
                playerController: playerController,
              ),
            ),
          ),
          child: Row(
            children: [
              SongArtwork(song: entry.value.first, size: 58, borderRadius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value.length} bài hát',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.tokens.textFaint),
            ],
          ),
        );
      },
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.libraryService,
    required this.playerController,
  });

  final String playlistId;
  final LibraryService libraryService;
  final PlayerController playerController;

  MusicPlaylist? _playlist() {
    for (final playlist in libraryService.playlists) {
      if (playlist.id == playlistId) return playlist;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: libraryService,
      builder: (context, _) {
        final playlist = _playlist();
        if (playlist == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.playlist_remove_rounded,
              title: 'Playlist không còn tồn tại',
              message: 'Playlist này có thể đã bị xóa.',
            ),
          );
        }
        final songs = libraryService.songsForPlaylist(playlist);
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              IconButton(
                onPressed: () => _showMenu(context, playlist),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          body: AppPage(
            safeTop: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: songs.isEmpty ? null : () => playerController.playAll(songs),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Phát tất cả'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: songs.isEmpty
                              ? null
                              : () => playerController.playAll(songs, shuffle: true),
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('Ngẫu nhiên'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: songs.isEmpty
                      ? const EmptyState(
                          icon: Icons.playlist_add_rounded,
                          title: 'Playlist chưa có bài hát',
                          message: 'Mở menu của một bài hát và chọn “Thêm vào playlist”.',
                          compact: true,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return SongTile(
                              song: song,
                              selected: playerController.currentSong?.id == song.id,
                              onTap: () => playerController.playSong(songs, song),
                              onMore: () => showSongActions(
                                context,
                                song: song,
                                libraryService: libraryService,
                                playerController: playerController,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMenu(BuildContext context, MusicPlaylist playlist) async {
    final selected = await showAppSelectionSheet<String>(
      context: context,
      title: playlist.name,
      options: const [
        AppSelectionOption(
          value: 'rename',
          title: 'Đổi tên playlist',
          icon: Icons.edit_outlined,
        ),
        AppSelectionOption(
          value: 'delete',
          title: 'Xóa playlist',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (!context.mounted || selected == null) return;
    if (selected == 'rename') {
      final name = await showAppTextPrompt(
        context: context,
        title: 'Đổi tên playlist',
        initialValue: playlist.name,
        placeholder: 'Tên playlist',
      );
      if (name != null) await libraryService.renamePlaylist(playlist.id, name);
      return;
    }
    final confirmed = await showAppConfirmation(
      context: context,
      title: 'Xóa playlist?',
      message: 'Các bài hát vẫn được giữ trong thư viện.',
      confirmLabel: 'Xóa',
      destructive: true,
    );
    if (confirmed) {
      await libraryService.deletePlaylist(playlist.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
