import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music/models/song.dart';
import 'package:offline_music/utils/app_theme.dart';
import 'package:offline_music/widgets/studio_widgets.dart';

void main() {
  test('song JSON round-trip preserves core metadata', () {
    final original = Song(
      id: '1',
      title: 'Bài hát',
      artist: 'Nghệ sĩ',
      album: 'Album',
      filePath: '/tmp/song.mp3',
      fileName: 'song.mp3',
      addedAt: DateTime.utc(2026, 8, 1),
      fileSize: 1024,
      durationMs: 123000,
      isFavorite: true,
    );
    final restored = Song.fromJson(original.toJson());
    expect(restored.title, original.title);
    expect(restored.artist, original.artist);
    expect(restored.durationMs, original.durationMs);
    expect(restored.isFavorite, isTrue);
  });

  testWidgets('flat surface renders in both light and dark themes', (tester) async {
    Future<void> pump(ThemeData theme) {
      return tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: SurfaceCard(child: Text('Studio Flat')),
            ),
          ),
        ),
      );
    }

    await pump(buildLightTheme());
    expect(find.text('Studio Flat'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pump(buildDarkTheme());
    expect(find.text('Studio Flat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
