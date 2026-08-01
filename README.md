# Offline Music V13.1 — Dark Rounded Fixed

Trình phát nhạc offline cho iPhone viết bằng Flutter. Bản này là **full source sạch**, sửa lỗi kiểm tra version trong workflow và giữ giao diện Dark Rounded: nền đen matte, card bo tròn, không gradient, không kính và không bóng 3D.

## Chức năng

- Nhập nhiều file nhạc từ ứng dụng Files.
- Hỗ trợ MP3, M4A, MP4, AAC, WAV, FLAC, OGG, OPUS và AIFF.
- Phát nền, màn hình khóa, Control Center và tai nghe.
- Phát/tạm dừng, tua, chuyển bài, trộn bài, lặp bài.
- Thư viện, tìm kiếm, sắp xếp, album, nghệ sĩ, thư mục và playlist.
- Yêu thích, lịch sử nghe, nghe gần đây và hẹn giờ tắt nhạc.
- Sửa tên bài hát, nghệ sĩ, album và ảnh bìa.
- Chọn ảnh từ Photos/Files hoặc tìm ảnh online bằng MusicBrainz và Cover Art Archive.
- Chế độ giao diện Theo hệ thống, Sáng và Tối; mặc định là Tối.

## Build IPA chưa ký

Workflow: `.github/workflows/build-ipa.yml`

Workflow tự động:

1. Tạo project iOS trên macOS runner.
2. Chạy `flutter pub get`.
3. Kiểm tra cấu trúc repo bằng `scripts/static_verify.py`.
4. Chạy `flutter analyze`.
5. Chạy `flutter test`.
6. Build `Runner.app` bằng `flutter build ios --release --no-codesign`.
7. Đóng gói thành `OfflineMusic-unsigned.ipa`.

Không cần certificate hoặc provisioning profile trong GitHub. IPA đầu ra dùng để ký bằng ESign.

## Cập nhật repo

Xóa toàn bộ source cũ trong repo **trừ thư mục `.git`**, sau đó chép toàn bộ nội dung bản này vào thư mục gốc repo. `pubspec.yaml` phải nằm ngay ngoài cùng.
