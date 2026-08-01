import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/app_modal.dart';
import 'cover_editor_screen.dart';
import '../widgets/song_tile.dart';

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
    final songs = widget.libraryService.search(query, source: widget.songs);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: AppBackdrop(
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Tìm bài hát...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: songs.isEmpty ? null : () => widget.playerController.playAll(songs),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Phát tất cả'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: songs.isEmpty ? null : () => widget.playerController.playAll(songs, shuffle: true),
                    icon: const Icon(Icons.shuffle_rounded, color: AppColors.accent),
                    label: const Text('Ngẫu nhiên'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
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
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            title: song.title,
            subtitle: song.artist,
          ),
          AppSheetAction(
            icon: song.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            title: song.isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
            onTap: () async {
              Navigator.pop(sheetContext);
              await libraryService.toggleFavorite(song.id);
            },
          ),
          const AppSheetDivider(),
          AppSheetAction(
            icon: Icons.image_outlined,
            title: 'Sửa ảnh bìa & thông tin',
            onTap: () async {
              Navigator.pop(sheetContext);
              await Future<void>.delayed(const Duration(milliseconds: 170));
              if (!rootContext.mounted) return;
              Navigator.of(rootContext).push(
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
              await Future<void>.delayed(const Duration(milliseconds: 170));
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
              await Future<void>.delayed(const Duration(milliseconds: 170));
              if (!rootContext.mounted) return;
              final confirmed = await showAppConfirmation(
                context: rootContext,
                title: 'Xóa bài hát?',
                message: 'File “${song.title}” sẽ bị xóa khỏi bộ nhớ ứng dụng.',
                confirmLabel: 'Xóa',
                destructive: true,
              );
              if (confirmed) {
                await libraryService.deleteSong(song.id);
                await playerController.refreshQueueMetadata();
              }
            },
          ),
        ],
      ),
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
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSheetHeader(
              title: 'Chọn playlist',
              subtitle: 'Chạm để thêm hoặc gỡ bài hát khỏi playlist.',
            ),
            if (libraryService.playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Text(
                  'Chưa có playlist. Hãy tạo playlist trong Thư viện.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: libraryService.playlists.length,
                  separatorBuilder: (_, __) => const AppSheetDivider(),
                  itemBuilder: (context, index) {
                    final playlist = libraryService.playlists[index];
                    final selected = playlist.songIds.contains(song.id);
                    return AppSheetAction(
                      icon: Icons.playlist_play_rounded,
                      title: playlist.name,
                      subtitle: '${playlist.songIds.length} bài hát',
                      selected: selected,
                      trailing: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 22,
                        color: selected
                            ? AppColors.accent
                            : AppColors.mutedSoft,
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
    ),
  );
}
