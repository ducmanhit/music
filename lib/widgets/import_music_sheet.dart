import 'package:flutter/material.dart';

import '../services/library_service.dart';
import 'app_modal.dart';

Future<void> showImportMusicSheet({
  required BuildContext context,
  required LibraryService libraryService,
}) async {
  final shouldImport = await showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSheetHeader(
          title: 'Thêm nhạc vào thư viện',
          subtitle: 'Chọn một hoặc nhiều file. Nhạc sẽ được sao chép vào bộ nhớ riêng của ứng dụng để nghe offline.',
        ),
        AppSheetAction(
          icon: Icons.folder_open_rounded,
          title: 'Chọn file âm thanh',
          subtitle: 'MP3, M4A, AAC, WAV, FLAC, OGG, OPUS và AIFF',
          onTap: () => Navigator.pop(sheetContext, true),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );

  if (shouldImport != true || !context.mounted) return;
  final result = await libraryService.importFromFiles();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(result.message)));
}
