# Offline Music V13 — Dark Rounded

Trình phát nhạc offline Flutter cho iPhone với giao diện dark premium, bo tròn, tối giản và không dùng gradient.

## Điểm mới
- Dark mode là giao diện mặc định.
- Now Playing có ảnh bìa lớn, điều khiển cố định và bố cục thích ứng màn hình thấp.
- Mini player và thanh điều hướng nổi, bo tròn, không bóng 3D.
- Surface đen/xám matte, viền mảnh, khoảng cách đồng bộ.
- Vẫn giữ chế độ sáng và lựa chọn theo hệ thống trong Cài đặt.
- Giữ đầy đủ chức năng nhập nhạc, playlist, yêu thích, sửa metadata/ảnh bìa, tìm ảnh online, phát nền, hẹn giờ và điều khiển màn hình khóa.

## Build IPA chưa ký
Workflow `.github/workflows/build-ipa.yml` chạy `flutter analyze`, test, build iOS không ký rồi đóng gói `Payload/Runner.app` thành IPA để ký bằng ESign.
