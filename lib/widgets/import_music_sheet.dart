import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../utils/app_theme.dart';
import 'app_modal.dart';

Future<void> showImportMusicSheet(
  BuildContext context, {
  required LibraryService libraryService,
}) async {
  final rootContext = context;
  final shouldImport = await showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(
            title: 'Thêm nhạc offline',
            subtitle:
                'Chọn một hoặc nhiều file trong ứng dụng Files. Bài hát sẽ được sao chép vào bộ nhớ riêng của app.',
          ),
          AppSheetAction(
            icon: Icons.folder_open_rounded,
            title: 'Chọn nhạc từ Files',
            subtitle: 'MP3, M4A, AAC, WAV, FLAC và định dạng phổ biến',
            trailing: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.accent,
              size: 24,
            ),
            onTap: () => Navigator.pop(sheetContext, true),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.graphite,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'App chỉ đọc các file bạn chọn, không tải nhạc và không yêu cầu đăng nhập.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (shouldImport != true) return;

  try {
    final result = await libraryService.importFromFiles();
    if (!rootContext.mounted) return;
    ScaffoldMessenger.of(rootContext).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  } catch (error) {
    if (!rootContext.mounted) return;
    ScaffoldMessenger.of(rootContext).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}
