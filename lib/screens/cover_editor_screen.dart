import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/online_cover_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/app_modal.dart';
import '../widgets/song_artwork.dart';
import '../widgets/studio_widgets.dart';

class CoverEditorScreen extends StatefulWidget {
  const CoverEditorScreen({
    super.key,
    required this.songId,
    required this.libraryService,
    required this.playerController,
  });

  final String songId;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<CoverEditorScreen> createState() => _CoverEditorScreenState();
}

class _CoverEditorScreenState extends State<CoverEditorScreen> {
  late final TextEditingController titleController;
  late final TextEditingController artistController;
  late final TextEditingController albumController;
  late final OnlineCoverService onlineCoverService;
  late final ImagePicker imagePicker;

  List<OnlineCoverResult> results = const [];
  bool saving = false;
  bool searching = false;
  bool searched = false;
  String? searchError;

  Song? get song => widget.libraryService.songById(widget.songId);

  @override
  void initState() {
    super.initState();
    final current = song;
    titleController = TextEditingController(text: current?.title ?? '');
    artistController = TextEditingController(text: current?.artist ?? '');
    albumController = TextEditingController(text: current?.album ?? '');
    onlineCoverService = OnlineCoverService();
    imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    albumController.dispose();
    onlineCoverService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.libraryService,
      builder: (context, _) {
        final current = song;
        if (current == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.music_off_rounded,
              title: 'Không tìm thấy bài hát',
              message: 'Bài hát có thể đã bị xóa khỏi thư viện.',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sửa bài hát'),
            actions: [
              TextButton(
                onPressed: saving ? null : _saveDetails,
                child: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AppPage(
            safeTop: false,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SongArtwork(
                        song: current,
                        size: 300,
                        borderRadius: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : _pickArtwork,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Chọn ảnh'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : _searchOnline,
                        icon: const Icon(Icons.travel_explore_rounded),
                        label: const Text('Tìm online'),
                      ),
                    ),
                  ],
                ),
                if (current.artworkPath != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: saving ? null : _removeArtwork,
                      icon: Icon(Icons.delete_outline_rounded, color: context.tokens.danger),
                      label: Text(
                        'Xóa ảnh bìa hiện tại',
                        style: TextStyle(color: context.tokens.danger),
                      ),
                    ),
                  ),
                ],
                const SectionHeader(
                  title: 'Thông tin bài hát',
                  padding: EdgeInsets.fromLTRB(0, 24, 0, 10),
                ),
                SurfaceCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tên bài hát',
                          prefixIcon: Icon(Icons.music_note_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: artistController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nghệ sĩ',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: albumController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saveDetails(),
                        decoration: const InputDecoration(
                          labelText: 'Album',
                          prefixIcon: Icon(Icons.album_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                if (searching) ...[
                  const SizedBox(height: 28),
                  const Center(child: CircularProgressIndicator()),
                ] else if (searched) ...[
                  SectionHeader(
                    title: 'Kết quả ảnh bìa',
                    subtitle: searchError ??
                        (results.isEmpty
                            ? 'Không tìm thấy kết quả phù hợp.'
                            : '${results.length} kết quả từ MusicBrainz'),
                    padding: const EdgeInsets.fromLTRB(0, 26, 0, 10),
                  ),
                  if (results.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: .72,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return _OnlineCoverCard(
                          result: result,
                          enabled: !saving,
                          onTap: () => _applyOnlineCover(result),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveDetails() async {
    final current = song;
    if (current == null || saving) return;
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Tên bài hát không được để trống.');
      return;
    }
    setState(() => saving = true);
    try {
      await widget.libraryService.updateSongDetails(
        current.id,
        title: title,
        artist: artistController.text,
        album: albumController.text,
      );
      await widget.playerController.refreshQueueMetadata();
      _showMessage('Đã lưu thông tin bài hát.');
    } catch (error) {
      _showMessage('Không thể lưu: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _pickArtwork() async {
    final selected = await showAppSelectionSheet<String>(
      context: context,
      title: 'Chọn ảnh bìa',
      options: const [
        AppSelectionOption(
          value: 'photos',
          title: 'Thư viện ảnh',
          icon: Icons.photo_library_outlined,
        ),
        AppSelectionOption(
          value: 'files',
          title: 'Chọn từ Files',
          icon: Icons.folder_open_rounded,
        ),
      ],
    );
    if (selected == 'photos') await _pickFromPhotos();
    if (selected == 'files') await _pickFromFiles();
  }

  Future<void> _pickFromPhotos() async {
    try {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
        maxWidth: 2200,
        maxHeight: 2200,
      );
      if (picked == null) return;
      await _replaceArtwork(File(picked.path));
    } catch (error) {
      _showMessage('Không thể chọn ảnh: $error');
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Chọn ảnh bìa',
        type: FileType.image,
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path == null) return;
      await _replaceArtwork(File(path));
    } catch (error) {
      _showMessage('Không thể chọn ảnh: $error');
    }
  }

  Future<void> _replaceArtwork(File file) async {
    final current = song;
    if (current == null || saving) return;
    setState(() => saving = true);
    try {
      await widget.libraryService.replaceArtworkFromFile(current.id, file);
      await widget.playerController.refreshQueueMetadata();
      _showMessage('Đã cập nhật ảnh bìa.');
    } catch (error) {
      _showMessage('Không thể cập nhật ảnh: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _removeArtwork() async {
    final current = song;
    if (current == null || saving) return;
    final confirmed = await showAppConfirmation(
      context: context,
      title: 'Xóa ảnh bìa?',
      message: 'Bài hát sẽ dùng ảnh mặc định của ứng dụng.',
      confirmLabel: 'Xóa ảnh',
      destructive: true,
    );
    if (!confirmed) return;
    setState(() => saving = true);
    try {
      await widget.libraryService.removeArtwork(current.id);
      await widget.playerController.refreshQueueMetadata();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _searchOnline() async {
    final title = titleController.text.trim();
    if (title.isEmpty || searching) {
      _showMessage('Nhập tên bài hát trước khi tìm ảnh.');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      searching = true;
      searched = false;
      searchError = null;
      results = const [];
    });
    try {
      final found = await onlineCoverService.search(
        title: title,
        artist: artistController.text,
      );
      if (!mounted) return;
      setState(() {
        results = found;
        searched = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        searchError = 'Không thể tìm ảnh: $error';
        searched = true;
      });
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> _applyOnlineCover(OnlineCoverResult result) async {
    final current = song;
    if (current == null || saving) return;
    setState(() => saving = true);
    try {
      final bytes = await onlineCoverService.download(result.imageUrl);
      await widget.libraryService.replaceArtworkFromBytes(current.id, bytes);
      await widget.playerController.refreshQueueMetadata();
      _showMessage('Đã dùng ảnh bìa “${result.title}”.');
    } catch (error) {
      _showMessage('Không thể tải ảnh: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OnlineCoverCard extends StatelessWidget {
  const _OnlineCoverCard({
    required this.result,
    required this.enabled,
    required this.onTap,
  });

  final OnlineCoverResult result;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        onTap: enabled ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: Image.network(
                  result.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: context.tokens.surfaceMuted,
                    child: Icon(Icons.broken_image_outlined, color: context.tokens.textMuted),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [result.artist, result.year].whereType<String>().join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
