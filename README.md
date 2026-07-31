# Offline Music V8 – Native Liquid Glass

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

## Giao diện V8

- Vật liệu kính được dựng lại bằng nhiều lớp: blur nền, lớp kính mỏng, viền khúc xạ theo hướng ánh sáng và phản chiếu cong.
- Giảm lớp trắng đục để nhìn xuyên nền rõ hơn, không dùng gradient xanh tím hoặc hiệu ứng neon.
- Sử dụng kiểu chữ hệ thống iOS, giảm độ đậm và khoảng cách chữ để giao diện gần ứng dụng Apple hơn.
- Thanh điều hướng có một thấu kính duy nhất trượt theo tab đang chọn thay vì bốn ô sáng riêng biệt.
- Mini Player mỏng hơn, nút điều khiển bằng kính trong thay cho nút đen nặng.
- Màn hình đang phát có ảnh bìa nổi, thanh công cụ dạng capsule, bảng điều khiển kính mỏng và bố cục cố định.
- Các card ở Trang chủ, Thư viện, Âm thanh và Cài đặt đã giảm opacity, tăng độ xuyên thấu và dùng cùng một hệ viền/bóng.
- Có hiệu ứng nhấn co nhẹ trên các vật thể kính để tạo cảm giác vật liệu nổi và mượt hơn.

## Build IPA chưa ký

Workflow nằm tại:

```text
.github/workflows/build-ipa.yml
```

Vào **Actions → Build iOS unsigned IPA → Run workflow**. Khi hoàn tất, tải artifact rồi giải nén để lấy file IPA chưa ký.

## Lưu ý

Ứng dụng chỉ phát file âm thanh do người dùng tự nhập. Tính năng tìm ảnh bìa online chỉ tải hình ảnh, không tải nhạc từ dịch vụ phát trực tuyến.
