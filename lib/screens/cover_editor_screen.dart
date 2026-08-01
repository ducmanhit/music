import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/song.dart';
import '../services/library_service.dart';
import '../services/online_cover_service.dart';
import '../services/player_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/song_artwork.dart';

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
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  bool _busy = false;

  Song? get _song => widget.libraryService.songById(widget.songId);

  @override
  void initState() {
    super.initState();
    final song = _song;
    _titleController = TextEditingController(text: song?.title ?? '');
    _artistController = TextEditingController(text: song?.artist ?? '');
    _albumController = TextEditingController(text: song?.album ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.libraryService,
      builder: (context, _) {
        final song = _song;
        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('Bài hát không còn trong thư viện')),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Ảnh bìa & thông tin'),
          ),
          body: AppBackdrop(
            child: AbsorbPointer(
            absorbing: _busy,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SongArtwork(
                        song: song,
                        size: 250,
                        borderRadius: 24,
                      ),
                      Positioned(
                        right: -8,
                        bottom: -8,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.edit_rounded,
                              color: AppColors.ink,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _SectionTitle(
                  title: 'Đổi ảnh bìa',
                  subtitle: 'Ảnh được lưu riêng trong ứng dụng, không sửa file nhạc gốc.',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.photo_library_outlined,
                        title: 'Photos',
                        subtitle: 'Chọn trong thư viện ảnh',
                        onTap: _pickFromPhotos,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.folder_open_rounded,
                        title: 'Files',
                        subtitle: 'Chọn JPG, PNG, HEIC',
                        onTap: _pickFromFiles,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WideActionCard(
                  icon: Icons.travel_explore,
                  title: 'Tìm ảnh bìa online',
                  subtitle: 'Tìm theo tên bài hát và nghệ sĩ',
                  onTap: () => _openOnlineSearch(song),
                ),
                if (song.artworkPath != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _removeArtwork,
                    icon: const Icon(Icons.hide_image_outlined),
                    label: const Text('Xóa ảnh bìa hiện tại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                const _SectionTitle(
                  title: 'Thông tin bài hát',
                  subtitle: 'Tên hiển thị trong ứng dụng và màn hình khóa.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tên bài hát',
                    prefixIcon: Icon(Icons.music_note_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _artistController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nghệ sĩ',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _albumController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveDetails(),
                  decoration: const InputDecoration(
                    labelText: 'Album',
                    prefixIcon: Icon(Icons.album_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saveDetails,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Lưu thay đổi'),
                ),
                if (_busy) ...[
                  const SizedBox(height: 18),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromPhotos() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 92,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    await _runArtworkTask(
      () => widget.libraryService.replaceArtworkFromFile(
        widget.songId,
        File(picked.path),
      ),
    );
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await _runArtworkTask(
      () => widget.libraryService.replaceArtworkFromFile(
        widget.songId,
        File(path),
      ),
    );
  }

  Future<void> _openOnlineSearch(Song song) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => OnlineCoverSearchScreen(
          songId: song.id,
          initialTitle: _titleController.text,
          initialArtist: _artistController.text,
          libraryService: widget.libraryService,
          playerController: widget.playerController,
        ),
      ),
    );
    if (changed == true && mounted) {
      _showMessage('Đã cập nhật ảnh bìa online.');
    }
  }

  Future<void> _removeArtwork() async {
    await _runArtworkTask(
      () => widget.libraryService.removeArtwork(widget.songId),
      message: 'Đã xóa ảnh bìa.',
    );
  }

  Future<void> _saveDetails() async {
    setState(() => _busy = true);
    try {
      await widget.libraryService.updateSongDetails(
        widget.songId,
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
      );
      await widget.playerController.refreshQueueMetadata();
      if (mounted) _showMessage('Đã lưu thông tin bài hát.');
    } catch (error) {
      if (mounted) _showMessage(_cleanError(error), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runArtworkTask(
    Future<void> Function() task, {
    String message = 'Đã cập nhật ảnh bìa.',
  }) async {
    setState(() => _busy = true);
    try {
      await task();
      await widget.playerController.refreshQueueMetadata();
      if (mounted) _showMessage(message);
    } catch (error) {
      if (mounted) _showMessage(_cleanError(error), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : null,
      ),
    );
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}

class OnlineCoverSearchScreen extends StatefulWidget {
  const OnlineCoverSearchScreen({
    super.key,
    required this.songId,
    required this.initialTitle,
    required this.initialArtist,
    required this.libraryService,
    required this.playerController,
  });

  final String songId;
  final String initialTitle;
  final String initialArtist;
  final LibraryService libraryService;
  final PlayerController playerController;

  @override
  State<OnlineCoverSearchScreen> createState() =>
      _OnlineCoverSearchScreenState();
}

class _OnlineCoverSearchScreenState extends State<OnlineCoverSearchScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  final OnlineCoverService _service = OnlineCoverService();
  List<OnlineCoverResult> _results = const [];
  bool _searching = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _artistController = TextEditingController(text: widget.initialArtist);
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tìm ảnh bìa online')),
      body: AppBackdrop(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tên bài hát hoặc album',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _artistController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        decoration: const InputDecoration(
                          labelText: 'Nghệ sĩ',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _searching ? null : _search,
                      child: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.public_rounded, size: 16, color: AppColors.muted),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Nguồn: MusicBrainz và Cover Art Archive.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_searching) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          Expanded(
            child: _results.isEmpty && !_searching
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Không tìm thấy ảnh phù hợp. Hãy thử rút gọn tên bài hát hoặc sửa tên nghệ sĩ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: .72,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return _CoverResultCard(
                        result: result,
                        disabled: _saving,
                        onTap: () => _select(result),
                      );
                    },
                  ),
          ),
          if (_saving)
            const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Đang tải và lưu ảnh bìa...'),
                  ],
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
      _results = const [];
    });
    try {
      final results = await _service.search(
        title: _titleController.text,
        artist: _artistController.text,
      );
      if (mounted) setState(() => _results = results);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _select(OnlineCoverResult result) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    result.imageUrl,
                    fit: BoxFit.cover,
                    headers: const {
                      'User-Agent':
                          'OfflineMusic/3.0 (https://github.com/ducmanhit/music)',
                    },
                    errorBuilder: (_, __, ___) => const _NetworkImageError(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                result.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                [result.artist, result.year].whereType<String>().join(' • '),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Dùng ảnh này'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final bytes = await _service.download(result.imageUrl);
      await widget.libraryService.replaceArtworkFromBytes(
        widget.songId,
        bytes,
      );
      await widget.playerController.refreshQueueMetadata();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CoverResultCard extends StatelessWidget {
  const _CoverResultCard({
    required this.result,
    required this.onTap,
    required this.disabled,
  });

  final OnlineCoverResult result;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: SizedBox.expand(
                    child: Image.network(
                      result.thumbnailUrl,
                      fit: BoxFit.cover,
                      headers: const {
                        'User-Agent':
                            'OfflineMusic/3.0 (https://github.com/ducmanhit/music)',
                      },
                      errorBuilder: (_, __, ___) => const _NetworkImageError(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                [result.artist, result.year].whereType<String>().join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkImageError extends StatelessWidget {
  const _NetworkImageError();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.muted),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, height: 1.35),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideActionCard extends StatelessWidget {
  const _WideActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .42),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: .25)),
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.accentDark,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: AppColors.accent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
