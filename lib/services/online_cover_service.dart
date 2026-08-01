import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OnlineCoverResult {
  const OnlineCoverResult({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.imageUrl,
    this.year,
    this.type,
  });

  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String imageUrl;
  final String? year;
  final String? type;
}

class OnlineCoverService {
  OnlineCoverService({http.Client? client}) : _client = client ?? http.Client();

  static const _userAgent =
      'OfflineMusic/12.0 (https://github.com/ducmanhit/music)';

  final http.Client _client;

  Future<List<OnlineCoverResult>> search({
    required String title,
    required String artist,
  }) async {
    final cleanTitle = title.trim();
    final cleanArtist = artist.trim();
    if (cleanTitle.isEmpty) return const [];

    final titleQuery = _escapeLucene(cleanTitle);
    final hasKnownArtist = cleanArtist.isNotEmpty &&
        cleanArtist.toLowerCase() != 'nghệ sĩ không rõ';
    final query = hasKnownArtist
        ? 'releasegroup:"$titleQuery" AND artist:"${_escapeLucene(cleanArtist)}"'
        : 'releasegroup:"$titleQuery"';

    final uri = Uri.https(
      'musicbrainz.org',
      '/ws/2/release-group/',
      <String, String>{
        'query': query,
        'fmt': 'json',
        'limit': '20',
      },
    );

    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': _userAgent,
          },
        )
        .timeout(const Duration(seconds: 18));

    if (response.statusCode != 200) {
      throw Exception('Không thể tìm ảnh bìa (${response.statusCode}).');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) return const [];
    final groups = decoded['release-groups'];
    if (groups is! List) return const [];

    final results = <OnlineCoverResult>[];
    final seen = <String>{};
    for (final raw in groups) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final id = item['id']?.toString() ?? '';
      final resultTitle = item['title']?.toString().trim() ?? '';
      if (id.isEmpty || resultTitle.isEmpty || !seen.add(id)) continue;

      final artistName = _artistCredit(item['artist-credit']);
      final date = item['first-release-date']?.toString();
      final year = date != null && date.length >= 4 ? date.substring(0, 4) : null;
      final type = item['primary-type']?.toString();

      results.add(
        OnlineCoverResult(
          id: id,
          title: resultTitle,
          artist: artistName.isEmpty ? 'Nghệ sĩ không rõ' : artistName,
          year: year,
          type: type,
          thumbnailUrl:
              'https://coverartarchive.org/release-group/$id/front-250',
          imageUrl:
              'https://coverartarchive.org/release-group/$id/front-1200',
        ),
      );
    }
    return results;
  }

  Future<Uint8List> download(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      throw Exception('Đường dẫn ảnh không hợp lệ.');
    }
    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'image/*',
            'User-Agent': _userAgent,
          },
        )
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw Exception('Không thể tải ảnh bìa (${response.statusCode}).');
    }
    if (response.bodyBytes.length > 12 * 1024 * 1024) {
      throw Exception('Ảnh bìa quá lớn.');
    }
    return response.bodyBytes;
  }

  String _artistCredit(dynamic value) {
    if (value is! List) return '';
    final parts = <String>[];
    for (final raw in value) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final name = item['name']?.toString().trim();
      if (name != null && name.isNotEmpty) parts.add(name);
      final join = item['joinphrase']?.toString();
      if (join != null && join.isNotEmpty) parts.add(join);
    }
    return parts.join().trim();
  }

  String _escapeLucene(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  }

  void dispose() => _client.close();
}
