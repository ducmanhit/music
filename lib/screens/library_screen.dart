import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import 'song_collection_screen.dart';

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

enum SongSort { title, artist, added, duration }

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  SongSort sort = SongSort.title;

  List<Song> _sortedSongs() {
    final result = widget.libraryService.search(query);
    switch (sort) {
      case SongSort.title:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SongSort.artist:
        result.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
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
    return AppBackdrop(
      child: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: 5,
          child: AnimatedBuilder(
            animation: widget.libraryService,
            builder: (context, _) {
              final songs = _sortedSongs();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 16, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bộ sưu tập',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Thư viện',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<SongSort>(
                          tooltip: 'Sắp xếp',
                          initialValue: sort,
                          onSelected: (value) => setState(() => sort = value),
                          icon: const Icon(Icons.sort_rounded),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: SongSort.title,
                              child: Text('Tên bài hát'),
                            ),
                            PopupMenuItem(
                              value: SongSort.artist,
                              child: Text('Nghệ sĩ'),
                            ),
                            PopupMenuItem(
                              value: SongSort.added,
                              child: Text('Ngày thêm'),
                            ),
                            PopupMenuItem(
                              value: SongSort.duration,
                              child: Text('Thời lượng'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        GlassIconButton(
                          icon: Icons.refresh_rounded,
                          tooltip: 'Quét lại thư viện',
                          onPressed: widget.libraryService.isImporting
                              ? null
                              : _rescan,
                        ),
                        const SizedBox(width: 8),
                        GlassIconButton(
                          icon: Icons.add_rounded,
                          tooltip: 'Nhập nhạc',
                          selected: true,
                          onPressed: widget.libraryService.isImporting
                              ? null
                              : _import,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: TextField(
                      onChanged: (value) => setState(() => query = value),
                      decoration: const InputDecoration(
                        hintText: 'Tìm bài hát, nghệ sĩ, album',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassPanel(
                      padding: EdgeInsets.zero,
                      borderRadius: 19,
                      blur: 14,
                      opacity: .72,
                      shadow: false,
                      child: const TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: 'Bài hát'),
                          Tab(text: 'Playlist'),
                          Tab(text: 'Thư mục'),
                          Tab(text: 'Nghệ sĩ'),
                          Tab(text: 'Album'),
                        ],
                      ),
                    ),
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
      ),
    );
  }

  Future<void> _import() => showImportMusicSheet(
        context,
        libraryService: widget.libraryService,
      );

  Future<void> _rescan() async {
    final result = await widget.libraryService.rescanMusicFolder();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Chưa có bài hát. Nhấn dấu + để nhập nhạc từ Files.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${songs.length} bài hát', style: const TextStyle(color: AppColors.muted, fontSize: 15)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => playerController.playAll(songs),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Phát tất cả'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => playerController.playAll(songs, shuffle: true),
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text('Phát ngẫu nhiên'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
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
  const _PlaylistsTab({required this.libraryService, required this.playerController});
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 150),
      children: [
        FilledButton.icon(
          onPressed: () => _createPlaylist(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tạo playlist mới'),
        ),
        const SizedBox(height: 14),
        if (libraryService.playlists.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              'Chưa có playlist.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        for (final playlist in libraryService.playlists)
          _PlaylistTile(
            playlist: playlist,
            libraryService: libraryService,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PlaylistDetailScreen(
                  playlistId: playlist.id,
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên playlist'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Tạo')),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) await libraryService.createPlaylist(name);
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.playlist, required this.libraryService, required this.onTap});
  final MusicPlaylist playlist;
  final LibraryService libraryService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final songs = libraryService.songsForPlaylist(playlist);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: songs.isEmpty
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.accentDark, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.queue_music_rounded, color: AppColors.accent),
            )
          : SongArtwork(song: songs.first, size: 56, borderRadius: 12),
      title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${songs.length} bài hát', style: const TextStyle(color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
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
    if (groups.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: AppColors.muted)));
    }
    final entries = groups.entries.toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: entry.value.isNotEmpty
              ? SongArtwork(song: entry.value.first, size: 54, borderRadius: 11)
              : Icon(icon),
          title: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${entry.value.length} bài hát', style: const TextStyle(color: AppColors.muted)),
          trailing: const Icon(Icons.chevron_right_rounded),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: libraryService,
      builder: (context, _) {
        final playlist = libraryService.playlists.where((item) => item.id == playlistId).firstOrNull;
        if (playlist == null) {
          return const Scaffold(body: Center(child: Text('Playlist đã bị xóa')));
        }
        final songs = libraryService.songsForPlaylist(playlist);
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') _rename(context, playlist);
                  if (value == 'delete') _delete(context, playlist);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa playlist')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
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
                        onPressed: songs.isEmpty ? null : () => playerController.playAll(songs, shuffle: true),
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Ngẫu nhiên'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? const Center(child: Text('Playlist chưa có bài hát', style: TextStyle(color: AppColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return SongTile(
                            song: song,
                            onTap: () => playerController.playSong(songs, song),
                            onMore: () => libraryService.toggleSongInPlaylist(playlist.id, song.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _rename(BuildContext context, MusicPlaylist playlist) async {
    final controller = TextEditingController(text: playlist.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên playlist'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Lưu')),
        ],
      ),
    );
    controller.dispose();
    if (name != null) await libraryService.renamePlaylist(playlist.id, name);
  }

  Future<void> _delete(BuildContext context, MusicPlaylist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa playlist?'),
        content: const Text('Các file nhạc không bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed == true) {
      await libraryService.deletePlaylist(playlist.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
