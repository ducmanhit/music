import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
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
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GlassPanel(
        borderRadius: 34,
        blur: 44,
        opacity: .16,
        shadow: true,
        pressable: false,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x443C3C43),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    song.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  title: Text(
                    song.isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await libraryService.toggleFavorite(song.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Sửa ảnh bìa & thông tin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
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
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: const Text('Thêm vào playlist'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showPlaylistPicker(
                      rootContext,
                      song: song,
                      libraryService: libraryService,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Xóa khỏi ứng dụng',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final confirmed = await showDialog<bool>(
                      context: rootContext,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Xóa bài hát?'),
                        content: Text(
                          'File “${song.title}” sẽ bị xóa khỏi bộ nhớ ứng dụng.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await libraryService.deleteSong(song.id);
                      await playerController.refreshQueueMetadata();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showPlaylistPicker(
  BuildContext context, {
  required Song song,
  required LibraryService libraryService,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: GlassPanel(
        borderRadius: 34,
        blur: 44,
        opacity: .16,
        shadow: true,
        pressable: false,
        child: AnimatedBuilder(
          animation: libraryService,
          builder: (context, _) => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0x443C3C43),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const ListTile(
                    title: Text(
                      'Chọn playlist',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (libraryService.playlists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có playlist. Hãy tạo playlist trong Thư viện.',
                      ),
                    ),
                  for (final playlist in libraryService.playlists)
                    CheckboxListTile(
                      value: playlist.songIds.contains(song.id),
                      title: Text(playlist.name),
                      subtitle: Text('${playlist.songIds.length} bài hát'),
                      onChanged: (_) => libraryService.toggleSongInPlaylist(
                        playlist.id,
                        song.id,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
