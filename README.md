# Offline Music V6 – Liquid Glass

Trình phát nhạc offline cho iPhone được xây dựng bằng Flutter, tối ưu để đóng gói IPA chưa ký bằng GitHub Actions và ký lại bằng ESign.

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
- Giao diện Liquid Glass sáng với nền xuyên thấu, blur thật, viền thấu kính, phản chiếu lăng kính và bố cục cố định trên nhiều kích thước iPhone.

## Build IPA chưa ký

Workflow nằm tại:

```text
.github/workflows/build-ipa.yml
```

Vào **Actions → Build iOS unsigned IPA → Run workflow**. Khi hoàn tất, tải artifact rồi giải nén để lấy file IPA chưa ký.

## Lưu ý

Ứng dụng chỉ phát file âm thanh do người dùng tự nhập. Tính năng tìm ảnh bìa online chỉ tải hình ảnh, không tải nhạc từ các dịch vụ phát trực tuyến.


## Giao diện V6

- Liquid Glass sáng, trung tính theo phong cách iOS.
- Không dùng gradient xanh tím hoặc hiệu ứng neon.
- Thanh điều hướng dạng viên thuốc kính nổi.
- Mini Player tách riêng, kính trắng và nút phát màu graphite.
- Màn hình đang phát giữ bố cục cố định, không trượt xuống.
- Popup, cài đặt, thư viện và nút điều khiển dùng cùng một hệ kính.
