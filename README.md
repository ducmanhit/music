# Offline Music V7 – iOS Clear Glass

Trình phát nhạc offline cho iPhone được xây dựng bằng Flutter, có workflow GitHub Actions để đóng gói IPA chưa ký và ký lại bằng ESign.

## Chức năng

- Nhập nhiều file nhạc từ ứng dụng Files.
- Sao chép bài hát vào bộ nhớ riêng để nghe hoàn toàn offline.
- Hỗ trợ MP3, M4A, AAC, WAV, FLAC, OGG, OPUS và AIFF.
- Đọc tên bài, nghệ sĩ, album, ảnh bìa, thời lượng, bitrate và sample rate.
- Sửa tên bài, nghệ sĩ, album và ảnh bìa.
- Chọn ảnh bìa từ Photos hoặc Files.
- Tìm ảnh bìa online bằng MusicBrainz và Cover Art Archive.
- Playlist, yêu thích, lịch sử nghe và mix hằng ngày.
- Phát nền, màn hình khóa, Control Center, tai nghe và Bluetooth.
- Trộn bài, lặp bài, tua nhạc, điều chỉnh âm lượng và hẹn giờ tắt.

## Giao diện V7

- Bỏ nền gradient xanh tím, glow và các khối kính đục của V6.
- Nền trắng/xám trung tính, kính mỏng, blur rõ và viền sáng nhẹ.
- Ít card hơn, khoảng trắng rộng hơn, icon và chữ đồng bộ theo phong cách iOS.
- Thanh điều hướng nổi dạng dock kính, tab được chọn nằm trong thấu kính riêng.
- Mini Player tách khỏi dock và chỉ xuất hiện khi có bài đang phát.
- Màn hình đang phát dùng bố cục cố định, tự co theo chiều cao màn hình và không cuộn trượt cụm điều khiển.
- Trang chủ, Thư viện, Âm thanh, Cài đặt và sheet nhập nhạc dùng cùng một hệ giao diện.

## Build IPA chưa ký

Workflow nằm tại:

```text
.github/workflows/build-ipa.yml
```

Vào **Actions → Build iOS unsigned IPA → Run workflow**. Khi hoàn tất, tải artifact rồi giải nén để lấy file IPA chưa ký.

## Lưu ý

Ứng dụng chỉ phát file âm thanh do người dùng tự nhập. Tính năng tìm ảnh bìa online chỉ tải hình ảnh, không tải nhạc từ dịch vụ phát trực tuyến.
