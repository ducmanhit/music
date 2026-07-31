# Offline Music V9 – Ultra Clear Liquid Glass

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

## Giao diện V9

- Nền trắng/xám rất nhạt, không còn gradient đen–trắng, xanh–tím hoặc hiệu ứng neon.
- Bỏ lớp hạt nhiễu để giao diện sạch và sáng hơn.
- Liquid Glass chỉ dùng cho điều hướng, mini player, popup, bottom sheet và nút điều khiển; nội dung chính giữ thoáng và dễ đọc.
- Kính dùng blur cao, lớp trắng cực mỏng, viền phản chiếu và bóng đổ trung tính.
- Thanh menu dưới trong suốt hơn, thấu kính tab đang chọn nhẹ hơn và chuyển động mượt.
- Mini Player trong hơn, thanh tiến trình dùng màu xanh hệ thống iOS.
- Màn hình phát nhạc giữ bố cục cố định, panel điều khiển mỏng và không bị trượt xuống.
- Ảnh bìa mặc định chuyển sang tông trắng/xám dịu, không còn nền đen gradient.
- Popup và bảng chọn playlist dùng cùng vật liệu kính để đồng bộ toàn ứng dụng.

## Build IPA chưa ký

Workflow nằm tại:

```text
.github/workflows/build-ipa.yml
```

Vào **Actions → Build iOS unsigned IPA → Run workflow**. Khi hoàn tất, tải artifact rồi giải nén để lấy file IPA chưa ký.

## Lưu ý

Ứng dụng chỉ phát file âm thanh do người dùng tự nhập. Tính năng tìm ảnh bìa online chỉ tải hình ảnh, không tải nhạc từ dịch vụ phát trực tuyến.
