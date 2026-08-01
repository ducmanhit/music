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
    return AppPage(
      child: DefaultTabController(
        length: 5,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            widget.libraryService,
            widget.playerController,
          ]),
          builder: (context, _) {
            final songs = _sortedSongs();
            return Column(
              children: [
                PageHeader(
                  eyebrow: 'Bộ sưu tập',
                  title: 'Thư viện',
                  subtitle:
                      '${widget.libraryService.songs.length} bài hát trong bộ nhớ ứng dụng',
                  actions: [
                    CircleIconButton(
                      icon: Icons.sort_rounded,
                      tooltip: 'Sắp xếp',
                      onPressed: _selectSort,
                    ),
                    CircleIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Làm mới thư viện',
                      onPressed: widget.libraryService.isImporting
                          ? null
                          : _rescan,
                    ),
                    CircleIconButton(
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AppSearchField(
                    hintText: 'Tìm trong thư viện',
                    onChanged: (value) => setState(() => query = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.tokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.tokens.border),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: 'Bài hát'),
                        Tab(text: 'Playlist'),
                        Tab(text: 'Nghệ sĩ'),
                        Tab(text: 'Album'),
                        Tab(text: 'Thư mục'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                        groups: widget.libraryService.byArtist,
                        icon: Icons.person_rounded,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _GroupsTab(
                        groups: widget.libraryService.byAlbum,
                        icon: Icons.album_rounded,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      ),
                      _GroupsTab(
                        groups: widget.libraryService.byFolder,
                        icon: Icons.folder_rounded,
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
          title: 'Ngày thêm',
          icon: Icons.schedule_rounded,
        ),
        AppSelectionOption(
          value: SongSort.duration,
          title: 'Thời lượng',
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
      return EmptyState(
        icon: Icons.music_note_rounded,
        title: 'Không có bài hát',
        message: libraryService.songs.isEmpty
            ? 'Nhấn dấu cộng để nhập nhạc từ ứng dụng Files.'
            : 'Không có bài hát phù hợp với từ khóa.',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Phát tất cả',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => playerController.playAll(songs),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: 'Ngẫu nhiên',
                  icon: Icons.shuffle_rounded,
                  onPressed: () => playerController.playAll(
                    songs,
                    shuffle: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            key: const PageStorageKey<String>('library-songs'),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: songs.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
            itemBuilder: (context, index) => SongTile(
              song: songs[index],
              source: songs,
              libraryService: libraryService,
              playerController: playerController,
            ),
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
    return ListView(
      key: const PageStorageKey<String>('library-playlists'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        SecondaryButton(
          label: 'Tạo playlist mới',
          icon: Icons.add_rounded,
          onPressed: () => _createPlaylist(context),
        ),
        const SizedBox(height: 16),
        if (playlists.isEmpty)
          const EmptyState(
            icon: Icons.queue_music_rounded,
            title: 'Chưa có playlist',
            message: 'Tạo playlist để sắp xếp nhạc theo sở thích.',
            compact: true,
          )
        else
          for (var index = 0; index < playlists.length; index++) ...[
            _PlaylistRow(
              playlist: playlists[index],
              libraryService: libraryService,
              playerController: playerController,
            ),
            if (index < playlists.length - 1)
              const Divider(height: 1, indent: 70),
          ],
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

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({
    required this.playlist,
    required this.libraryService,
    required this.playerController,
  });

  final MusicPlaylist playlist;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final songs = libraryService.songsForPlaylist(playlist);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SongCollectionScreen(
              title: playlist.name,
              subtitle: '${songs.length} bài hát',
              songs: songs,
              playlist: playlist,
              libraryService: libraryService,
              playerController: playerController,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _PlaylistArtwork(songs: songs),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${songs.length} bài hát',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.tokens.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistArtwork extends StatelessWidget {
  const _PlaylistArtwork({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: context.tokens.surfaceHigh,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.queue_music_rounded,
          color: context.tokens.textSecondary,
        ),
      );
    }
    return SongArtwork(
      song: songs.first,
      size: 54,
      borderRadius: 15,
      showBorder: false,
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.groups,
    required this.icon,
    required this.libraryService,
    required this.playerController,
  });

  final Map<String, List<Song>> groups;
  final IconData icon;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    final entries = groups.entries.toList();
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: 'Chưa có dữ liệu',
        message: 'Thông tin sẽ được tạo từ metadata của file nhạc.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final artwork = entry.value.first;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SongCollectionScreen(
                  title: entry.key,
                  subtitle: '${entry.value.length} bài hát',
                  songs: entry.value,
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SongArtwork(
                        song: artwork,
                        size: 54,
                        borderRadius: 15,
                        showBorder: false,
                      ),
                      if (artwork.artworkPath == null)
                        Icon(icon, color: context.tokens.textPrimary),
                    ],
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${entry.value.length} bài hát',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.tokens.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
