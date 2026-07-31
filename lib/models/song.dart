class Song {
  const Song({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileName,
    required this.addedAt,
    required this.fileSize,
    this.artist = 'Nghệ sĩ không rõ',
    this.album = 'Không rõ album',
    this.folder = 'Music',
    this.artworkPath,
    this.lyrics,
    this.durationMs = 0,
    this.bitrateKbps,
    this.sampleRate,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String folder;
  final String filePath;
  final String fileName;
  final String? artworkPath;
  final String? lyrics;
  final DateTime addedAt;
  final int durationMs;
  final int fileSize;
  final int? bitrateKbps;
  final int? sampleRate;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayedAt;

  Duration get duration => Duration(milliseconds: durationMs);
  String get extension {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toUpperCase();
  }

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    String? folder,
    String? filePath,
    String? fileName,
    String? artworkPath,
    bool clearArtwork = false,
    String? lyrics,
    DateTime? addedAt,
    int? durationMs,
    int? fileSize,
    int? bitrateKbps,
    int? sampleRate,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayedAt,
  }) {
    return Song(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      folder: folder ?? this.folder,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      artworkPath: clearArtwork ? null : (artworkPath ?? this.artworkPath),
      lyrics: lyrics ?? this.lyrics,
      addedAt: addedAt ?? this.addedAt,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      sampleRate: sampleRate ?? this.sampleRate,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'folder': folder,
        'filePath': filePath,
        'fileName': fileName,
        'artworkPath': artworkPath,
        'lyrics': lyrics,
        'addedAt': addedAt.toIso8601String(),
        'durationMs': durationMs,
        'fileSize': fileSize,
        'bitrateKbps': bitrateKbps,
        'sampleRate': sampleRate,
        'isFavorite': isFavorite,
        'playCount': playCount,
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      };

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Không rõ tên',
      artist: (json['artist'] as String?) ?? 'Nghệ sĩ không rõ',
      album: (json['album'] as String?) ?? 'Không rõ album',
      folder: (json['folder'] as String?) ?? 'Music',
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      artworkPath: json['artworkPath'] as String?,
      lyrics: json['lyrics'] as String?,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      bitrateKbps: (json['bitrateKbps'] as num?)?.toInt(),
      sampleRate: (json['sampleRate'] as num?)?.toInt(),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      lastPlayedAt: DateTime.tryParse(json['lastPlayedAt'] as String? ?? ''),
    );
  }
}
