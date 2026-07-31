import 'package:flutter/cupertino.dart';
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
        result.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSort.artist:
        result.sort((a, b) =>
            a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BỘ SƯU TẬP',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.15,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Thư viện',
                                style: TextStyle(
                                  fontSize: 34,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SortButton(
                          value: sort,
                          onSelected: (value) => setState(() => sort = value),
                        ),
                        const SizedBox(width: 7),
                        GlassIconButton(
                          icon: CupertinoIcons.refresh,
                          tooltip: 'Quét lại thư viện',
                          onPressed: widget.libraryService.isImporting
                              ? null
                              : _rescan,
                        ),
                        const SizedBox(width: 7),
                        GlassIconButton(
                          icon: CupertinoIcons.add,
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: GlassPanel(
                      borderRadius: 24,
                      blur: 36,
                      opacity: .075,
                      shadow: false,
                      child: TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: const InputDecoration(
                          filled: false,
                          hintText: 'Tìm bài hát, nghệ sĩ, album',
                          prefixIcon: Icon(CupertinoIcons.search),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(4),
                      borderRadius: 23,
                      blur: 36,
                      opacity: .065,
                      shadow: false,
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .78),
                          ),
                        ),
                        indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                        tabs: const [
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
                          icon: CupertinoIcons.folder,
                          libraryService: widget.libraryService,
                          playerController: widget.playerController,
                        ),
                        _GroupsTab(
                          groups: widget.libraryService.byArtist,
                          emptyText: 'Chưa có thông tin nghệ sĩ',
                          icon: CupertinoIcons.person,
                          libraryService: widget.libraryService,
                          playerController: widget.playerController,
                        ),
                        _GroupsTab(
                          groups: widget.libraryService.byAlbum,
                          emptyText: 'Chưa có thông tin album',
                          icon: CupertinoIcons.music_albums,
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

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onSelected});

  final SongSort value;
  final ValueChanged<SongSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SongSort>(
      tooltip: 'Sắp xếp',
      initialValue: value,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => const [
        PopupMenuItem(value: SongSort.title, child: Text('Tên bài hát')),
        PopupMenuItem(value: SongSort.artist, child: Text('Nghệ sĩ')),
        PopupMenuItem(value: SongSort.added, child: Text('Ngày thêm')),
        PopupMenuItem(value: SongSort.duration, child: Text('Thời lượng')),
      ],
      child: const SizedBox.square(
        dimension: 46,
        child: GlassPanel(
          borderRadius: 23,
          blur: 34,
          opacity: .08,
          shadow: false,
          child: Center(
            child: Icon(
              Icons.sort_rounded,
              size: 21,
              color: AppColors.graphite,
            ),
          ),
        ),
      ),
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
      return const _EmptyState(
        icon: CupertinoIcons.music_note_list,
        title: 'Chưa có bài hát',
        subtitle: 'Nhấn dấu + để nhập nhạc từ Files.',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: CupertinoIcons.play_fill,
                  label: 'Phát tất cả',
                  primary: true,
                  onTap: () => playerController.playAll(songs),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: CupertinoIcons.shuffle,
                  label: 'Ngẫu nhiên',
                  onTap: () => playerController.playAll(songs, shuffle: true),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${songs.length} bài hát',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 150),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      blur: 34,
      opacity: primary ? .18 : .07,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.graphite),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 150),
      children: [
        _ActionButton(
          icon: CupertinoIcons.add,
          label: 'Tạo playlist mới',
          primary: true,
          onTap: () => _createPlaylist(context),
        ),
        const SizedBox(height: 16),
        if (libraryService.playlists.isEmpty)
          const SizedBox(
            height: 300,
            child: _EmptyState(
              icon: CupertinoIcons.music_note_list,
              title: 'Chưa có playlist',
              subtitle: 'Tạo playlist để sắp xếp những bài bạn thích.',
            ),
          ),
        for (final playlist in libraryService.playlists)
          _PlaylistTile(
            playlist: playlist,
            libraryService: libraryService,
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await libraryService.createPlaylist(name);
    }
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.playlist,
    required this.libraryService,
    required this.onTap,
  });

  final MusicPlaylist playlist;
  final LibraryService libraryService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final songs = libraryService.songsForPlaylist(playlist);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GlassPanel(
        borderRadius: 22,
        blur: 34,
        opacity: .065,
        shadow: false,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
        child: Row(
          children: [
            songs.isEmpty
                ? Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .36),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(CupertinoIcons.music_note_list),
                  )
                : SongArtwork(song: songs.first, size: 55, borderRadius: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${songs.length} bài hát',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, size: 18),
          ],
        ),
      ),
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
      return _EmptyState(
        icon: icon,
        title: emptyText,
        subtitle: 'Thông tin sẽ xuất hiện khi file nhạc có metadata phù hợp.',
      );
    }
    final entries = groups.entries.toList();
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 150),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: GlassPanel(
            borderRadius: 22,
            blur: 34,
            opacity: .06,
            shadow: false,
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => SongCollectionScreen(
                  title: entry.key,
                  songs: entry.value,
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
            child: Row(
              children: [
                entry.value.isNotEmpty
                    ? SongArtwork(
                        song: entry.value.first,
                        size: 55,
                        borderRadius: 17,
                      )
                    : Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${entry.value.length} bài hát',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_forward, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: Colors.white.withValues(alpha: .82)),
              ),
              child: Icon(icon, size: 28, color: AppColors.graphite),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
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
        final playlist = libraryService.playlists
            .where((item) => item.id == playlistId)
            .firstOrNull;
        if (playlist == null) {
          return const Scaffold(body: Center(child: Text('Playlist đã bị xóa')));
        }
        final songs = libraryService.songsForPlaylist(playlist);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppBackdrop(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        GlassIconButton(
                          icon: CupertinoIcons.back,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.6,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') _rename(context, playlist);
                            if (value == 'delete') _delete(context, playlist);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                            PopupMenuItem(value: 'delete', child: Text('Xóa playlist')),
                          ],
                          child: const GlassIconButton(
                            icon: CupertinoIcons.ellipsis,
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: CupertinoIcons.play_fill,
                            label: 'Phát tất cả',
                            primary: true,
                            onTap: songs.isEmpty
                                ? () {}
                                : () => playerController.playAll(songs),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: CupertinoIcons.shuffle,
                            label: 'Ngẫu nhiên',
                            onTap: songs.isEmpty
                                ? () {}
                                : () => playerController.playAll(
                                      songs,
                                      shuffle: true,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: songs.isEmpty
                        ? const _EmptyState(
                            icon: CupertinoIcons.music_note_list,
                            title: 'Playlist chưa có bài hát',
                            subtitle: 'Thêm bài hát từ menu của từng bài.',
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return SongTile(
                                song: song,
                                onTap: () =>
                                    playerController.playSong(songs, song),
                                onMore: () => libraryService
                                    .toggleSongInPlaylist(playlist.id, song.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Lưu'),
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
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
