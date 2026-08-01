# Offline Music Studio V12

Trình phát nhạc offline cho iPhone được viết bằng Flutter. V12 là một bản thiết kế mới hoàn toàn theo phong cách **Studio Flat**: phẳng, rõ ràng, không kính, không gradient, không bóng 3D và hỗ trợ giao diện sáng/tối độc lập.

## Điểm mới của V12

- Thiết kế Material 3 trung tính, khác hoàn toàn giao diện iOS Liquid Glass cũ.
- Ba chế độ giao diện: Theo hệ thống, Sáng và Tối.
- Lựa chọn giao diện được lưu cục bộ và khôi phục sau khi mở lại app.
- Thanh điều hướng phẳng, mini player liền mạch và không dùng hiệu ứng nổi.
- Trang chủ, thư viện, màn hình phát, âm thanh, cài đặt, popup và trình sửa ảnh bìa được xây lại đồng bộ.
- Không sử dụng `LinearGradient`, `RadialGradient`, `SweepGradient` hoặc `BoxShadow` trong thư mục `lib`.
- Popup dùng bề mặt Material đặc, Safe Area, giới hạn chiều cao và hỗ trợ bàn phím.
- Workflow kiểm tra cấu trúc, chạy `flutter analyze`, `flutter test`, build iOS không ký và kiểm tra nội dung IPA.

## Chức năng

- Nhập nhiều file nhạc từ Files.
- Hỗ trợ MP3, M4A, MP4, AAC, WAV, FLAC, OGG, OPUS và AIFF.
- Phát nền, màn hình khóa, Control Center và tai nghe.
- Tìm kiếm, sắp xếp, yêu thích, playlist, nhóm theo thư mục/nghệ sĩ/album.
- Trộn bài, lặp bài, hẹn giờ tắt nhạc, điều chỉnh âm lượng.
- Sửa tên bài, nghệ sĩ, album và ảnh bìa.
- Chọn ảnh từ Photos, Files hoặc tìm ảnh online bằng MusicBrainz/Cover Art Archive.
- Hiển thị định dạng, bitrate, sample rate, thời lượng và dung lượng thư viện.

## Build IPA chưa ký bằng GitHub Actions

Workflow nằm tại:

```text
.github/workflows/build-ipa.yml
```

Sau khi push lên nhánh `main`:

1. Mở tab **Actions**.
2. Chọn **Build unsigned IPA**.
3. Chờ toàn bộ bước chuyển màu xanh.
4. Tải artifact **Offline-Music-Unsigned-IPA**.
5. Giải nén để nhận `OfflineMusic-unsigned.ipa`.
6. Ký IPA bằng ESign.

## Các bước kiểm tra trong workflow

```text
python3 scripts/static_verify.py
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --reporter expanded
flutter build ios --release --no-codesign
unzip -l OfflineMusic-unsigned.ipa
```

Không thể đảm bảo tuyệt đối 100% trên mọi phiên bản iOS nếu chưa cài thử IPA lên thiết bị thật. Workflow được thiết kế để chặn lỗi cấu trúc, lỗi analyzer, lỗi widget test, lỗi build Xcode và lỗi đóng gói IPA trước khi artifact được xuất ra.
