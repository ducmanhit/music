import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/playlist.dart';
import '../models/song.dart';

enum MusicImportSource { files, googleDrive, oneDrive }

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });

  final int imported;
  final int skipped;
  final int failed;

  String get message => 'Đã thêm $imported • Bỏ qua $skipped • Lỗi $failed';
}

class LibraryService extends ChangeNotifier {
  static const supportedExtensions = <String>[
    'mp3',
    'm4a',
    'mp4',
    'aac',
    'wav',
    'flac',
    'ogg',
    'opus',
    'aiff',
    'aif',
  ];

  final List<Song> _songs = [];
  final List<MusicPlaylist> _playlists = [];
  Directory? _documentsDirectory;
  Directory? _musicDirectory;
  Directory? _artworkDirectory;
  File? _databaseFile;
  bool _isReady = false;
  bool _isImporting = false;

  List<Song> get songs => List.unmodifiable(_songs);
  Song? songById(String id) {
    for (final song in _songs) {
      if (song.id == id) return song;
    }
    return null;
  }
  List<MusicPlaylist> get playlists => List.unmodifiable(_playlists);
  bool get isReady => _isReady;
  bool get isImporting => _isImporting;
  Directory? get musicDirectory => _musicDirectory;
  int get favoriteCount => _songs.where((song) => song.isFavorite).length;
  int get totalPlayCount => _songs.fold(0, (sum, song) => sum + song.playCount);

  List<Song> get favorites =>
      _songs.where((song) => song.isFavorite).toList(growable: false);

  List<Song> get recentlyPlayed {
    final items = _songs.where((song) => song.lastPlayedAt != null).toList();
    items.sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return items;
  }

  List<Song> get dailyMix {
    final items = List<Song>.from(_songs);
    items.sort((a, b) {
      final playCompare = b.playCount.compareTo(a.playCount);
      if (playCompare != 0) return playCompare;
      return b.addedAt.compareTo(a.addedAt);
    });
    return items;
  }

  Map<String, List<Song>> get byArtist => _groupBy((song) => song.artist);
  Map<String, List<Song>> get byAlbum => _groupBy((song) => song.album);
  Map<String, List<Song>> get byFolder => _groupBy((song) => song.folder);

  Future<void> initialize() async {
    _documentsDirectory = await getApplicationDocumentsDirectory();
    _musicDirectory = Directory(p.join(_documentsDirectory!.path, 'Music'));
    _artworkDirectory = Directory(p.join(_documentsDirectory!.path, 'Artwork'));
    _databaseFile = File(p.join(_documentsDirectory!.path, 'offline_music.json'));

    await _musicDirectory!.create(recursive: true);
    await _artworkDirectory!.create(recursive: true);

    if (await _databaseFile!.exists()) {
      try {
        final decoded = jsonDecode(await _databaseFile!.readAsString());
        if (decoded is Map<String, dynamic>) {
          final songList = decoded['songs'] as List<dynamic>? ?? const [];
          final playlistList = decoded['playlists'] as List<dynamic>? ?? const [];
          _songs
            ..clear()
            ..addAll(
              songList
                  .map((item) => Song.fromJson(item as Map<String, dynamic>))
                  .where((song) => File(song.filePath).existsSync()),
            );
          _playlists
            ..clear()
            ..addAll(
              playlistList.map(
                (item) => MusicPlaylist.fromJson(item as Map<String, dynamic>),
              ),
            );
        }
      } catch (_) {
        _songs.clear();
        _playlists.clear();
      }
    }

    await _removeMissingArtworkReferences();
    _sortSongs();
    _isReady = true;
    notifyListeners();
  }

  Future<ImportResult> importFromFiles() =>
      importFromPicker(MusicImportSource.files);

  Future<ImportResult> importFromPicker(
    MusicImportSource source,
  ) async {
    if (_isImporting) {
      return const ImportResult(imported: 0, skipped: 0, failed: 0);
    }

    final dialogTitle = switch (source) {
      MusicImportSource.files => 'Chọn file nhạc',
      MusicImportSource.googleDrive => 'Chọn nhạc từ Google Drive',
      MusicImportSource.oneDrive => 'Chọn nhạc từ OneDrive',
    };
    final result = await FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: supportedExtensions,
      withData: false,
      withReadStream: false,
    );
    if (result == null) {
      return const ImportResult(imported: 0, skipped: 0, failed: 0);
    }

    final files = <({File file, String name})>[];
    for (final picked in result.files) {
      if (picked.path != null) {
        files.add((file: File(picked.path!), name: picked.name));
      }
    }
    return importExternalFiles(files);
  }

  Future<ImportResult> importExternalFiles(
    List<({File file, String name})> files,
  ) async {
    if (_musicDirectory == null || _artworkDirectory == null || _isImporting) {
      return const ImportResult(imported: 0, skipped: 0, failed: 0);
    }

    _isImporting = true;
    notifyListeners();
    var imported = 0;
    var skipped = 0;
    var failed = 0;

    try {
      for (var index = 0; index < files.length; index++) {
        final source = files[index].file;
        final originalName = files[index].name;
        if (!await source.exists() || !_isSupported(originalName)) {
          failed++;
          continue;
        }

        final sourceSize = await source.length();
        final duplicate = _songs.any(
          (song) =>
              song.fileName.toLowerCase() == originalName.toLowerCase() &&
              song.fileSize == sourceSize,
        );
        if (duplicate) {
          skipped++;
          continue;
        }

        try {
          final destinationName = await _availableFileName(originalName);
          final destination = File(p.join(_musicDirectory!.path, destinationName));
          await source.copy(destination.path);
          final song = await _createSongFromFile(
            destination,
            originalName: originalName,
            index: index,
          );
          _songs.add(song);
          imported++;
        } catch (_) {
          failed++;
        }
      }
      _sortSongs();
      await _save();
    } finally {
      _isImporting = false;
      notifyListeners();
    }

    return ImportResult(imported: imported, skipped: skipped, failed: failed);
  }

  Future<ImportResult> rescanMusicFolder() async {
    if (_musicDirectory == null || _isImporting) {
      return const ImportResult(imported: 0, skipped: 0, failed: 0);
    }
    final files = await _musicDirectory!
        .list(recursive: true, followLinks: false)
        .where((entry) => entry is File)
        .cast<File>()
        .where((file) => _isSupported(file.path))
        .toList();

    _isImporting = true;
    notifyListeners();
    var imported = 0;
    var skipped = 0;
    var failed = 0;
    try {
      for (var index = 0; index < files.length; index++) {
        final file = files[index];
        if (_songs.any((song) => song.filePath == file.path)) {
          skipped++;
          continue;
        }
        try {
          _songs.add(
            await _createSongFromFile(
              file,
              originalName: p.basename(file.path),
              index: index,
            ),
          );
          imported++;
        } catch (_) {
          failed++;
        }
      }
      _sortSongs();
      await _save();
    } finally {
      _isImporting = false;
      notifyListeners();
    }
    return ImportResult(imported: imported, skipped: skipped, failed: failed);
  }

  Future<Song> _createSongFromFile(
    File file, {
    required String originalName,
    required int index,
  }) async {
    final fileStat = await file.stat();
    final fallbackTitle = p.basenameWithoutExtension(originalName).trim();
    String title = fallbackTitle.isEmpty ? 'Không rõ tên' : fallbackTitle;
    String artist = 'Nghệ sĩ không rõ';
    String album = 'Không rõ album';
    String? artworkPath;
    String? lyrics;
    var durationMs = 0;
    int? bitrateKbps;
    int? sampleRate;

    try {
      final metadata = readMetadata(file, getImage: true);
      final metaTitle = metadata.title?.trim();
      final metaArtist = metadata.artist?.trim();
      final metaAlbum = metadata.album?.trim();
      if (metaTitle != null && metaTitle.isNotEmpty) title = metaTitle;
      if (metaArtist != null && metaArtist.isNotEmpty) artist = metaArtist;
      if (metaAlbum != null && metaAlbum.isNotEmpty) album = metaAlbum;
      durationMs = metadata.duration?.inMilliseconds ?? 0;
      sampleRate = metadata.sampleRate;
      final rawBitrate = metadata.bitrate;
      if (rawBitrate != null && rawBitrate > 0) {
        bitrateKbps = rawBitrate > 10000 ? (rawBitrate / 1000).round() : rawBitrate;
      }
      final rawLyrics = metadata.lyrics?.trim();
      if (rawLyrics != null && rawLyrics.isNotEmpty) lyrics = rawLyrics;
      if (metadata.pictures.isNotEmpty) {
        artworkPath = await _writeArtwork(
          metadata.pictures.first.bytes,
          metadata.pictures.first.mimetype,
          '${DateTime.now().microsecondsSinceEpoch}_$index',
        );
      }
    } catch (_) {
      // File vẫn được thêm bằng tên file nếu metadata bị lỗi.
    }

    final relativeFolder = p.relative(p.dirname(file.path), from: _musicDirectory!.path);
    final folder = relativeFolder == '.' ? 'Music' : relativeFolder;
    final now = DateTime.now();
    return Song(
      id: '${now.microsecondsSinceEpoch}_$index',
      title: title,
      artist: artist,
      album: album,
      folder: folder,
      filePath: file.path,
      fileName: originalName,
      artworkPath: artworkPath,
      lyrics: lyrics,
      addedAt: now,
      durationMs: durationMs,
      fileSize: fileStat.size,
      bitrateKbps: bitrateKbps,
      sampleRate: sampleRate,
    );
  }

  Future<String> _writeArtwork(Uint8List bytes, String mimeType, String id) async {
    final extension = switch (mimeType.toLowerCase()) {
      'image/png' => '.png',
      'image/webp' => '.webp',
      _ => '.jpg',
    };
    final file = File(p.join(_artworkDirectory!.path, '$id$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }


  Future<void> updateSongDetails(
    String songId, {
    required String title,
    required String artist,
    required String album,
  }) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) return;
    _songs[index] = _songs[index].copyWith(
      title: title.trim().isEmpty ? _songs[index].title : title.trim(),
      artist: artist.trim().isEmpty ? 'Nghệ sĩ không rõ' : artist.trim(),
      album: album.trim().isEmpty ? 'Không rõ album' : album.trim(),
    );
    _sortSongs();
    await _save();
    notifyListeners();
  }

  Future<void> replaceArtworkFromFile(String songId, File source) async {
    if (_artworkDirectory == null || !await source.exists()) return;
    final length = await source.length();
    if (length <= 0 || length > 15 * 1024 * 1024) {
      throw Exception('Ảnh phải nhỏ hơn 15 MB.');
    }

    final extension = _safeImageExtension(source.path);
    final destination = File(
      p.join(
        _artworkDirectory!.path,
        '${songId}_${DateTime.now().microsecondsSinceEpoch}$extension',
      ),
    );
    await source.copy(destination.path);
    await _replaceArtworkPath(songId, destination.path);
  }

  Future<void> replaceArtworkFromBytes(
    String songId,
    Uint8List bytes, {
    String extension = '.jpg',
  }) async {
    if (_artworkDirectory == null || bytes.isEmpty) return;
    if (bytes.length > 15 * 1024 * 1024) {
      throw Exception('Ảnh phải nhỏ hơn 15 MB.');
    }
    final safeExtension = _safeImageExtension('cover$extension');
    final destination = File(
      p.join(
        _artworkDirectory!.path,
        '${songId}_${DateTime.now().microsecondsSinceEpoch}$safeExtension',
      ),
    );
    await destination.writeAsBytes(bytes, flush: true);
    await _replaceArtworkPath(songId, destination.path);
  }

  Future<void> removeArtwork(String songId) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) return;
    final oldPath = _songs[index].artworkPath;
    _songs[index] = _songs[index].copyWith(clearArtwork: true);
    await _save();
    await _deleteArtwork(oldPath);
    notifyListeners();
  }

  Future<void> _replaceArtworkPath(String songId, String newPath) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) {
      await _deleteArtwork(newPath);
      return;
    }
    final oldPath = _songs[index].artworkPath;
    _songs[index] = _songs[index].copyWith(artworkPath: newPath);
    await _save();
    if (oldPath != newPath) await _deleteArtwork(oldPath);
    notifyListeners();
  }

  Future<void> _deleteArtwork(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {
        // Không chặn thao tác nếu file ảnh cũ không thể xóa.
      }
    }
  }

  String _safeImageExtension(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    return switch (extension) {
      '.png' => '.png',
      '.webp' => '.webp',
      '.heic' => '.heic',
      '.heif' => '.heif',
      '.jpeg' => '.jpg',
      '.jpg' => '.jpg',
      _ => '.jpg',
    };
  }

  Future<void> toggleFavorite(String songId) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) return;
    _songs[index] = _songs[index].copyWith(isFavorite: !_songs[index].isFavorite);
    await _save();
    notifyListeners();
  }

  Future<void> recordPlayed(String songId) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) return;
    _songs[index] = _songs[index].copyWith(
      playCount: _songs[index].playCount + 1,
      lastPlayedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> deleteSong(String songId) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index < 0) return;
    final song = _songs.removeAt(index);
    final audio = File(song.filePath);
    if (await audio.exists()) await audio.delete();
    if (song.artworkPath != null) {
      final artwork = File(song.artworkPath!);
      if (await artwork.exists()) await artwork.delete();
    }
    for (var i = 0; i < _playlists.length; i++) {
      _playlists[i] = _playlists[i].copyWith(
        songIds: _playlists[i].songIds.where((id) => id != songId).toList(),
        updatedAt: DateTime.now(),
      );
    }
    await _save();
    notifyListeners();
  }

  Future<void> clearLibrary() async {
    for (final song in List<Song>.from(_songs)) {
      final audio = File(song.filePath);
      if (await audio.exists()) await audio.delete();
      if (song.artworkPath != null) {
        final artwork = File(song.artworkPath!);
        if (await artwork.exists()) await artwork.delete();
      }
    }
    _songs.clear();
    _playlists.clear();
    await _save();
    notifyListeners();
  }

  Future<MusicPlaylist> createPlaylist(String name) async {
    final now = DateTime.now();
    final playlist = MusicPlaylist(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Playlist mới' : name.trim(),
      songIds: const [],
      createdAt: now,
      updatedAt: now,
    );
    _playlists.add(playlist);
    await _save();
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String id, String name) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == id);
    if (index < 0 || name.trim().isEmpty) return;
    _playlists[index] = _playlists[index].copyWith(
      name: name.trim(),
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((playlist) => playlist.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleSongInPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index < 0) return;
    final ids = List<String>.from(_playlists[index].songIds);
    if (ids.contains(songId)) {
      ids.remove(songId);
    } else {
      ids.add(songId);
    }
    _playlists[index] = _playlists[index].copyWith(
      songIds: ids,
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  List<Song> songsForPlaylist(MusicPlaylist playlist) {
    final byId = {for (final song in _songs) song.id: song};
    return playlist.songIds.map((id) => byId[id]).whereType<Song>().toList();
  }

  List<Song> search(String query, {Iterable<Song>? source}) {
    final normalized = query.trim().toLowerCase();
    final items = source ?? _songs;
    if (normalized.isEmpty) return List<Song>.from(items);
    return items
        .where(
          (song) =>
              song.title.toLowerCase().contains(normalized) ||
              song.artist.toLowerCase().contains(normalized) ||
              song.album.toLowerCase().contains(normalized) ||
              song.fileName.toLowerCase().contains(normalized),
        )
        .toList();
  }

  Future<int> storageBytes() async {
    var total = 0;
    for (final song in _songs) {
      total += song.fileSize;
    }
    return total;
  }

  Map<String, List<Song>> _groupBy(String Function(Song song) keyOf) {
    final result = <String, List<Song>>{};
    for (final song in _songs) {
      result.putIfAbsent(keyOf(song), () => []).add(song);
    }
    final entries = result.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return {for (final entry in entries) entry.key: entry.value};
  }

  bool _isSupported(String fileName) {
    final extension = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    return supportedExtensions.contains(extension);
  }

  Future<String> _availableFileName(String originalName) async {
    final safeBase = p.basenameWithoutExtension(originalName)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    final extension = p.extension(originalName).toLowerCase();
    final base = safeBase.isEmpty ? 'audio' : safeBase;
    var candidate = '$base$extension';
    var number = 2;
    while (await File(p.join(_musicDirectory!.path, candidate)).exists()) {
      candidate = '$base ($number)$extension';
      number++;
    }
    return candidate;
  }

  void _sortSongs() {
    _songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  Future<void> _removeMissingArtworkReferences() async {
    for (var index = 0; index < _songs.length; index++) {
      final path = _songs[index].artworkPath;
      if (path != null && !File(path).existsSync()) {
        _songs[index] = _songs[index].copyWith(clearArtwork: true);
      }
    }
  }

  Future<void> _save() async {
    if (_databaseFile == null) return;
    final data = jsonEncode({
      'songs': _songs.map((song) => song.toJson()).toList(),
      'playlists': _playlists.map((playlist) => playlist.toJson()).toList(),
    });
    await _databaseFile!.writeAsString(data, flush: true);
  }
}
