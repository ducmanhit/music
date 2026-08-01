import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum AppThemeChoice { system, light, dark }

class AppPreferences extends ChangeNotifier {
  AppPreferences({Directory? storageDirectory})
      : _storageDirectoryOverride = storageDirectory;

  final Directory? _storageDirectoryOverride;
  AppThemeChoice _themeChoice = AppThemeChoice.dark;
  File? _file;
  bool _initialized = false;

  AppThemeChoice get themeChoice => _themeChoice;
  bool get initialized => _initialized;

  ThemeMode get themeMode => switch (_themeChoice) {
        AppThemeChoice.system => ThemeMode.system,
        AppThemeChoice.light => ThemeMode.light,
        AppThemeChoice.dark => ThemeMode.dark,
      };

  Future<void> initialize() async {
    if (_initialized) return;
    final directory = _storageDirectoryOverride ??
        await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);
    _file = File(p.join(directory.path, 'app_preferences.json'));

    if (await _file!.exists()) {
      try {
        final decoded = jsonDecode(await _file!.readAsString());
        if (decoded is Map<String, dynamic>) {
          final value = decoded['theme']?.toString();
          _themeChoice = AppThemeChoice.values.firstWhere(
            (choice) => choice.name == value,
            orElse: () => AppThemeChoice.dark,
          );
        }
      } catch (_) {
        _themeChoice = AppThemeChoice.dark;
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeChoice(AppThemeChoice choice) async {
    if (_themeChoice == choice) return;
    _themeChoice = choice;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    if (_file == null) return;
    final payload = jsonEncode(<String, dynamic>{
      'theme': _themeChoice.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await _file!.writeAsString(payload, flush: true);
  }
}
