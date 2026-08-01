import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music/services/app_preferences.dart';

void main() {
  group('AppPreferences theme persistence', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'offline_music_theme_',
      );
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('uses dark mode by default for the Dark Rounded edition', () async {
      final preferences = AppPreferences(storageDirectory: directory);

      await preferences.initialize();

      expect(preferences.themeChoice, AppThemeChoice.dark);
      expect(preferences.themeMode, ThemeMode.dark);
    });

    test('persists dark, light and system choices to JSON storage', () async {
      final first = AppPreferences(storageDirectory: directory);
      await first.initialize();

      await first.setThemeChoice(AppThemeChoice.light);
      expect(first.themeMode, ThemeMode.light);

      final second = AppPreferences(storageDirectory: directory);
      await second.initialize();
      expect(second.themeChoice, AppThemeChoice.light);
      expect(second.themeMode, ThemeMode.light);

      await second.setThemeChoice(AppThemeChoice.system);
      expect(second.themeMode, ThemeMode.system);

      final third = AppPreferences(storageDirectory: directory);
      await third.initialize();
      expect(third.themeChoice, AppThemeChoice.system);
      expect(third.themeMode, ThemeMode.system);

      await third.setThemeChoice(AppThemeChoice.dark);

      final fourth = AppPreferences(storageDirectory: directory);
      await fourth.initialize();
      expect(fourth.themeChoice, AppThemeChoice.dark);
      expect(fourth.themeMode, ThemeMode.dark);
    });

    test('falls back to dark mode when preferences JSON is invalid', () async {
      final file = File('${directory.path}/app_preferences.json');
      await file.writeAsString('{not valid json');

      final preferences = AppPreferences(storageDirectory: directory);
      await preferences.initialize();

      expect(preferences.themeChoice, AppThemeChoice.dark);
      expect(preferences.themeMode, ThemeMode.dark);
    });
  });
}
