import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/import_music_sheet.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_tile.dart';
import 'song_collection_screen.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.libraryService,
            widget.playerController,
          ]),
          builder: (context, _) {
            final library = widget.libraryService;
            final searchResults = library.search(query);
            final recent = library.recentlyPlayed.take(8).toList();
            final mix = library.dailyMix.take(8).toList();
            final favorites = library.favorites.take(8).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OFFLINE MUSIC',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.15,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Dành cho bạn',
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
                        GlassIconButton(
                          icon: CupertinoIcons.gear_alt,
                          tooltip: 'Cài đặt',
                          onPressed: () => widget.onNavigate(3),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
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
                ),
                if (query.trim().isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 155),
                    sliver: searchResults.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(
                                child: Text(
                                  'Không tìm thấy bài hát phù hợp',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ),
                            ),
                          )
                        : SliverList.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final song = searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SongTile(
                                  song: song,
                                  onTap: () => widget.playerController
                                      .playSong(searchResults, song),
                                  onMore: () => showSongActions(
                                    context,
                                    song: song,
                                    libraryService: library,
                                    playerController: widget.playerController,
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _LibrarySummary(
                        library: library,
                        onTap: () => widget.onNavigate(2),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickAction(
                              icon: CupertinoIcons.time,
                              label: 'Lịch sử',
                              onTap: () => _openCollection(
                                context,
                                'Lịch sử nghe',
                                library.recentlyPlayed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickAction(
                              icon: CupertinoIcons.timer,
                              label: 'Hẹn giờ',
                              onTap: () => _showAudioTools(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickAction(
                              icon: CupertinoIcons.add,
                              label: 'Thêm nhạc',
                              onTap: () => showImportMusicSheet(
                                context,
                                libraryService: library,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (library.songs.isEmpty)
                    SliverToBoxAdapter(
                      child: _EmptyHome(
                        importing: library.isImporting,
                        onImport: () => showImportMusicSheet(
                          context,
                          libraryService: library,
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: 'Mix hằng ngày',
                        subtitle: 'Từ thư viện của bạn',
                        songs: mix,
                        libraryService: library,
                        playerController: widget.playerController,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: recent.isEmpty ? 'Mới thêm' : 'Nghe gần đây',
                        subtitle: recent.isEmpty
                            ? 'Những bài vừa được nhập'
                            : 'Tiếp tục nghe',
                        songs: recent.isEmpty
                            ? library.songs.take(8).toList()
                            : recent,
                        libraryService: library,
                        playerController: widget.playerController,
                      ),
                    ),
                    if (favorites.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _HorizontalSection(
                          title: 'Yêu thích',
                          subtitle: 'Những bài bạn đã lưu',
                          songs: favorites,
                          libraryService: library,
                          playerController: widget.playerController,
                        ),
                      ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 160)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openCollection(BuildContext context, String title, List<Song> songs) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SongCollectionScreen(
          title: title,
          songs: songs,
          libraryService: widget.libraryService,
          playerController: widget.playerController,
        ),
      ),
    );
  }

  Future<void> _showAudioTools(BuildContext context) async {
    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: GlassPanel(
          borderRadius: 36,
          blur: 44,
          opacity: .16,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0x553C3C43),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hẹn giờ tắt nhạc',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final minutes in [10, 20, 30, 45, 60, 90])
                    ListTile(
                      leading: const Icon(CupertinoIcons.timer),
                      title: Text('$minutes phút'),
                      trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
                      onTap: () => Navigator.pop(
                        context,
                        Duration(minutes: minutes),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(CupertinoIcons.clear_circled),
                    title: const Text('Tắt hẹn giờ'),
                    onTap: () => Navigator.pop(context, Duration.zero),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    widget.playerController.setSleepTimer(
      selected == Duration.zero ? null : selected,
    );
  }
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({required this.library, required this.onTap});

  final LibraryService library;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 31,
      blur: 36,
      opacity: .095,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(19, 18, 17, 18),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .42),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: Colors.white.withValues(alpha: .88),
              ),
            ),
            child: const Icon(
              CupertinoIcons.music_note_list,
              color: AppColors.accent,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thư viện của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${library.songs.length} bài hát  •  ${library.playlists.length} playlist',
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
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      blur: 34,
      opacity: .07,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .80)),
            ),
            child: Icon(icon, size: 20, color: AppColors.graphite),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.subtitle,
    required this.songs,
    required this.libraryService,
    required this.playerController,
  });

  final String title;
  final String subtitle;
  final List<Song> songs;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.55,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => playerController.playAll(songs),
                  child: const Text('Phát tất cả'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final song = songs[index];
                return GestureDetector(
                  onTap: () => playerController.playSong(songs, song),
                  onLongPress: () => showSongActions(
                    context,
                    song: song,
                    libraryService: libraryService,
                    playerController: playerController,
                  ),
                  child: SizedBox(
                    width: 136,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SongArtwork(
                          song: song,
                          size: 136,
                          borderRadius: 25,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.importing, required this.onImport});

  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 35, 22, 0),
      child: GlassPanel(
        borderRadius: 32,
        blur: 38,
        opacity: .08,
        shadow: false,
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 34),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .30),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: .82)),
              ),
              child: const Icon(
                CupertinoIcons.music_note_2,
                size: 31,
                color: AppColors.graphite,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Thư viện đang trống',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập nhạc từ ứng dụng Files để nghe hoàn toàn offline.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: importing ? null : onImport,
              icon: importing
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Icon(CupertinoIcons.add),
              label: Text(importing ? 'Đang nhập…' : 'Chọn file nhạc'),
            ),
          ],
        ),
      ),
    );
  }
}
