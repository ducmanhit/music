import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/app_modal.dart';
import '../widgets/song_tile.dart';
import '../widgets/studio_widgets.dart';
import 'cover_editor_screen.dart';

class SongCollectionScreen extends StatefulWidget {
  const SongCollectionScreen({
    super.key,
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
  State<SongCollectionScreen> createState() => _SongCollectionScreenState();
}

class _SongCollectionScreenState extends State<SongCollectionScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final currentIds = widget.libraryService.songs.map((song) => song.id).toSet();
    final source = widget.songs.where((song) => currentIds.contains(song.id)).toList();
    final songs = widget.libraryService.search(query, source: source);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: AppPage(
        safeTop: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Tìm trong danh sách',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () => widget.playerController.playAll(songs),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Phát tất cả'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: songs.isEmpty
                          ? null
                          : () => widget.playerController.playAll(songs, shuffle: true),
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
                      icon: Icons.music_off_rounded,
                      title: 'Không có bài hát',
                      message: 'Danh sách này chưa có bài hát hoặc không khớp từ khóa.',
                      compact: true,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SongTile(
                          song: song,
                          selected: widget.playerController.currentSong?.id == song.id,
                          onTap: () => widget.playerController.playSong(songs, song),
                          onMore: () => showSongActions(
                            context,
                            song: song,
                            libraryService: widget.libraryService,
                            playerController: widget.playerController,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSongActions(
  BuildContext context, {
  required Song song,
  required LibraryService libraryService,
  required PlayerController playerController,
}) async {
  final rootContext = context;
  await showAppSheet<void>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSheetHeader(title: song.title, subtitle: song.artist),
        AppSheetAction(
          icon: song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          title: song.isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
          onTap: () async {
            Navigator.pop(sheetContext);
            await libraryService.toggleFavorite(song.id);
          },
        ),
        const AppSheetDivider(),
        AppSheetAction(
          icon: Icons.edit_note_rounded,
          title: 'Sửa thông tin và ảnh bìa',
          onTap: () async {
            Navigator.pop(sheetContext);
            await Future<void>.delayed(const Duration(milliseconds: 120));
            if (!rootContext.mounted) return;
            await Navigator.of(rootContext).push(
              MaterialPageRoute<void>(
                builder: (_) => CoverEditorScreen(
                  songId: song.id,
                  libraryService: libraryService,
                  playerController: playerController,
                ),
              ),
            );
          },
        ),
        const AppSheetDivider(),
        AppSheetAction(
          icon: Icons.playlist_add_rounded,
          title: 'Thêm vào playlist',
          onTap: () async {
            Navigator.pop(sheetContext);
            await Future<void>.delayed(const Duration(milliseconds: 120));
            if (!rootContext.mounted) return;
            await showPlaylistPicker(
              rootContext,
              song: song,
              libraryService: libraryService,
            );
          },
        ),
        const AppSheetDivider(),
        AppSheetAction(
          icon: Icons.delete_outline_rounded,
          title: 'Xóa khỏi ứng dụng',
          destructive: true,
          onTap: () async {
            Navigator.pop(sheetContext);
            await Future<void>.delayed(const Duration(milliseconds: 120));
            if (!rootContext.mounted) return;
            final confirmed = await showAppConfirmation(
              context: rootContext,
              title: 'Xóa bài hát?',
              message: 'File “${song.title}” sẽ bị xóa khỏi bộ nhớ ứng dụng.',
              confirmLabel: 'Xóa',
              destructive: true,
            );
            if (!confirmed) return;
            await libraryService.deleteSong(song.id);
            await playerController.refreshQueueMetadata();
          },
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

Future<void> showPlaylistPicker(
  BuildContext context, {
  required Song song,
  required LibraryService libraryService,
}) async {
  await showAppSheet<void>(
    context: context,
    builder: (sheetContext) => AnimatedBuilder(
      animation: libraryService,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(
            title: 'Chọn playlist',
            subtitle: 'Chạm để thêm hoặc gỡ bài hát.',
          ),
          if (libraryService.playlists.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
              child: Text(
                'Chưa có playlist. Hãy tạo playlist trong Thư viện.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.tokens.textMuted,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .58,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: libraryService.playlists.length,
                separatorBuilder: (_, __) => const AppSheetDivider(),
                itemBuilder: (context, index) {
                  final playlist = libraryService.playlists[index];
                  final selected = playlist.songIds.contains(song.id);
                  return AppSheetAction(
                    icon: Icons.queue_music_rounded,
                    title: playlist.name,
                    subtitle: '${playlist.songIds.length} bài hát',
                    selected: selected,
                    trailing: Icon(
                      selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : context.tokens.textFaint,
                    ),
                    onTap: () => libraryService.toggleSongInPlaylist(
                      playlist.id,
                      song.id,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}
