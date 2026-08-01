import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music/services/app_preferences.dart';

void main() {
  test('theme choice persists to local JSON storage', () async {
    final directory = await Directory.systemTemp.createTemp('offline_music_theme_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final first = AppPreferences(storageDirectory: directory);
    await first.initialize();
    expect(first.themeChoice, AppThemeChoice.system);
    expect(first.themeMode, ThemeMode.system);

    await first.setThemeChoice(AppThemeChoice.dark);
    expect(first.themeMode, ThemeMode.dark);

    final second = AppPreferences(storageDirectory: directory);
    await second.initialize();
    expect(second.themeChoice, AppThemeChoice.dark);
    expect(second.themeMode, ThemeMode.dark);
  });
}
