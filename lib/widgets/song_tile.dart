import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../screens/cover_editor_screen.dart';
import 'app_modal.dart';
import 'song_artwork.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.source,
    required this.libraryService,
    required this.playerController,
    this.showIndex,
    this.showDivider = false,
  });

  final Song song;
  final List<Song> source;
  final LibraryService libraryService;
  final PlayerController playerController;
  final int? showIndex;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final active = playerController.currentSong?.id == song.id;
    return Container(
      decoration: BoxDecoration(
        color: active ? context.tokens.surfaceHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => playerController.playSong(source, song),
          borderRadius: BorderRadius.circular(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  if (showIndex != null) ...[
                    SizedBox(
                      width: 30,
                      child: Text(
                        showIndex!.toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: context.tokens.textTertiary,
                            ),
                      ),
                    ),
                  ],
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SongArtwork(
                        song: song,
                        size: 52,
                        borderRadius: 14,
                        showBorder: false,
                      ),
                      if (active)
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            playerController.player.playing
                                ? Icons.graphic_eq_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${song.artist} • ${song.extension}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (song.durationMs > 0)
                    Text(
                      formatDuration(song.duration),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: context.tokens.textTertiary,
                          ),
                    ),
                  IconButton(
                    onPressed: () => _showActions(context),
                    tooltip: 'Tùy chọn',
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: context.tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showAppSelectionSheet<String>(
      context: context,
      title: song.title,
      subtitle: song.artist,
      options: [
        AppSelectionOption(
          value: 'favorite',
          title: song.isFavorite ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích',
          icon: song.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
        ),
        const AppSelectionOption(
          value: 'playlist',
          title: 'Thêm vào playlist',
          icon: Icons.playlist_add_rounded,
        ),
        const AppSelectionOption(
          value: 'edit',
          title: 'Sửa thông tin và ảnh bìa',
          icon: Icons.edit_rounded,
        ),
        const AppSelectionOption(
          value: 'delete',
          title: 'Xóa khỏi thư viện',
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'favorite':
        await libraryService.toggleFavorite(song.id);
        break;
      case 'playlist':
        await _choosePlaylist(context);
        break;
      case 'edit':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CoverEditorScreen(
              songId: song.id,
              libraryService: libraryService,
              playerController: playerController,
            ),
          ),
        );
        break;
      case 'delete':
        final confirmed = await showAppConfirmation(
          context: context,
          title: 'Xóa bài hát?',
          message:
              'File nhạc và ảnh bìa của “${song.title}” sẽ bị xóa khỏi ứng dụng.',
          confirmLabel: 'Xóa',
          destructive: true,
        );
        if (confirmed) {
          await libraryService.deleteSong(song.id);
          await playerController.refreshQueueMetadata();
        }
        break;
    }
  }

  Future<void> _choosePlaylist(BuildContext context) async {
    if (libraryService.playlists.isEmpty) {
      final name = await showAppTextPrompt(
        context: context,
        title: 'Tạo playlist',
        placeholder: 'Tên playlist',
      );
      if (name == null) return;
      final playlist = await libraryService.createPlaylist(name);
      await libraryService.toggleSongInPlaylist(playlist.id, song.id);
      return;
    }

    final selected = await showAppSelectionSheet<String>(
      context: context,
      title: 'Thêm vào playlist',
      options: [
        for (final playlist in libraryService.playlists)
          AppSelectionOption(
            value: playlist.id,
            title: playlist.name,
            subtitle: '${playlist.songIds.length} bài hát',
            icon: Icons.queue_music_rounded,
          ),
      ],
    );
    if (selected != null) {
      await libraryService.toggleSongInPlaylist(selected, song.id);
    }
  }
}
