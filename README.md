# Offline Music V14 — Dark Rounded Premium

Trình phát nhạc offline bằng Flutter dành cho iPhone. Bản V14 được xây lại theo một hệ giao diện tối, phẳng, bo tròn và đồng bộ; không dùng gradient, kính mờ hoặc hiệu ứng neon.

## Chức năng

- Nhập nhiều file nhạc từ ứng dụng Files.
- Hỗ trợ MP3, M4A, MP4, AAC, WAV, FLAC, OGG, OPUS và AIFF.
- Sao chép file vào bộ nhớ riêng để nghe hoàn toàn offline.
- Phát nền, màn hình khóa, Control Center và tai nghe.
- Tìm kiếm, sắp xếp, playlist, nghệ sĩ, album và thư mục.
- Yêu thích, lịch sử nghe và danh sách chờ.
- Hẹn giờ tắt nhạc và điều chỉnh âm lượng.
- Sửa tên bài hát, nghệ sĩ, album và ảnh bìa.
- Chọn ảnh từ Photos/Files hoặc tìm ảnh bìa online.
- Ba chế độ giao diện: Theo hệ thống, Sáng và Tối.

## Thiết kế V14

- Dark Rounded Premium là giao diện mặc định.
- Không gradient, không BackdropFilter, không neon.
- Bottom navigation 4 tab: Trang chủ, Tìm kiếm, Thư viện, Cài đặt.
- Mini Player 68 px, bo 24 px, có tiến trình phát.
- Now Playing dùng LayoutBuilder, khóa portrait và không dùng cuộn cho bố cục chính.
- Bottom sheet dùng Safe Area, giới hạn 82% chiều cao và tự nâng khi bàn phím mở.

## Build IPA chưa ký

Workflow `.github/workflows/build-ipa.yml` chạy trên macOS:

1. Tạo project iOS.
2. Cài dependencies.
3. Kiểm tra cấu trúc repository.
4. Chạy `flutter analyze`.
5. Chạy `flutter test`.
6. Build `Runner.app` với `--no-codesign`.
7. Đóng gói `Payload/Runner.app` thành `OfflineMusic-unsigned.ipa`.

IPA được tải trong phần **Artifacts** của GitHub Actions và có thể ký lại bằng công cụ của bạn.
