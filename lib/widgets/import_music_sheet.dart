import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../utils/app_theme.dart';

Future<void> showImportMusicSheet(
  BuildContext context, {
  required LibraryService libraryService,
}) async {
  final rootContext = context;
  final shouldImport = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lineStrong,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Thêm nhạc offline',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -.45,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Chọn một hoặc nhiều file nhạc trong ứng dụng Files. Bài hát sẽ được sao chép vào bộ nhớ riêng của app.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 20),
          GlassPanel(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            blur: 12,
            opacity: .24,
            onTap: () => Navigator.pop(context, true),
            child: const Row(
              children: [
                _ImportIcon(),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn nhạc từ Files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'MP3, M4A, AAC, WAV, FLAC và các định dạng phổ biến',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: AppColors.accent, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'App chỉ đọc các file bạn chọn và không cần đăng nhập tài khoản đám mây.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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

class _ImportIcon extends StatelessWidget {
  const _ImportIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A0A84FF),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(Icons.folder_open_rounded, color: Colors.white),
    );
  }
}
