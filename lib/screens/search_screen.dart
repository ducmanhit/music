import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/studio_widgets.dart';
import 'song_collection_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.libraryService,
    required this.playerController,
  });

  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          widget.libraryService,
          widget.playerController,
        ]),
        builder: (context, _) {
          final results = widget.libraryService.search(query);
          return CustomScrollView(
            key: const PageStorageKey<String>('search-page'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: 'Khám phá thư viện',
                  title: 'Tìm kiếm',
                  subtitle: 'Tìm theo tên bài hát, nghệ sĩ hoặc album.',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: AppSearchField(
                    controller: controller,
                    focusNode: focusNode,
                    hintText: 'Tìm bài hát, nghệ sĩ, album',
                    onChanged: (value) => setState(() => query = value),
                    trailing: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              controller.clear();
                              setState(() => query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              if (query.trim().isEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Nghệ sĩ',
                    subtitle: '${widget.libraryService.byArtist.length} nghệ sĩ',
                  ),
                ),
                _SuggestionList(
                  items: widget.libraryService.byArtist.entries
                      .take(6)
                      .map(
                        (entry) => _Suggestion(
                          title: entry.key,
                          subtitle: '${entry.value.length} bài hát',
                          icon: Icons.person_rounded,
                          songs: entry.value,
                        ),
                      )
                      .toList(),
                  libraryService: widget.libraryService,
                  playerController: widget.playerController,
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Album',
                    subtitle: '${widget.libraryService.byAlbum.length} album',
                  ),
                ),
                _SuggestionList(
                  items: widget.libraryService.byAlbum.entries
                      .take(6)
                      .map(
                        (entry) => _Suggestion(
                          title: entry.key,
                          subtitle: '${entry.value.length} bài hát',
                          icon: Icons.album_rounded,
                          songs: entry.value,
                        ),
                      )
                      .toList(),
                  libraryService: widget.libraryService,
                  playerController: widget.playerController,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ] else if (results.isEmpty) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Không có kết quả',
                    message: 'Thử một từ khóa khác hoặc kiểm tra tên bài hát.',
                  ),
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Kết quả',
                    subtitle: '${results.length} bài hát phù hợp',
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 68,
                    ),
                    itemBuilder: (context, index) {
                      final song = results[index];
                      return SongTile(
                        song: song,
                        source: results,
                        libraryService: widget.libraryService,
                        playerController: widget.playerController,
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.songs,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Song> songs;
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.items,
    required this.libraryService,
    required this.playerController,
  });

  final List<_Suggestion> items;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: EmptyState(
            icon: Icons.music_note_rounded,
            title: 'Chưa có dữ liệu',
            message: 'Nghệ sĩ và album sẽ xuất hiện sau khi bạn nhập nhạc.',
            compact: true,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SongCollectionScreen(
                    title: item.title,
                    subtitle: item.subtitle,
                    songs: item.songs,
                    libraryService: libraryService,
                    playerController: playerController,
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.tokens.surfaceHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          color: context.tokens.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
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
      ),
    );
  }
}
