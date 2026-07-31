import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../utils/app_theme.dart';

Future<void> showImportMusicSheet(
  BuildContext context, {
  required LibraryService libraryService,
}) async {
  final rootContext = context;
  final source = await showModalBottomSheet<MusicImportSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Thêm nhạc',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            const Text(
              'Chọn một hoặc nhiều file nhạc. App sẽ sao chép vào bộ nhớ riêng để nghe offline.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            _ImportTile(
              icon: Icons.folder_open_rounded,
              title: 'Từ ứng dụng Files',
              subtitle: 'Bộ nhớ iPhone, iCloud Drive và các vị trí khác',
              onTap: () => Navigator.pop(context, MusicImportSource.files),
            ),
            const SizedBox(height: 10),
            _ImportTile(
              icon: Icons.add_to_drive_outlined,
              title: 'Từ Google Drive',
              subtitle: 'Mở trình chọn file và chọn Google Drive trong Duyệt',
              onTap: () =>
                  Navigator.pop(context, MusicImportSource.googleDrive),
            ),
            const SizedBox(height: 10),
            _ImportTile(
              icon: Icons.cloud_outlined,
              title: 'Từ OneDrive',
              subtitle: 'Mở trình chọn file và chọn OneDrive trong Duyệt',
              onTap: () => Navigator.pop(context, MusicImportSource.oneDrive),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.backgroundSoft,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.line),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.accent, size: 19),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Google Drive hoặc OneDrive phải được cài và bật trong Files → Duyệt → dấu ba chấm → Sửa.',
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
    ),
  );
  if (source == null) return;

  try {
    final result = await libraryService.importFromPicker(source);
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

class _ImportTile extends StatelessWidget {
  const _ImportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.accentDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
