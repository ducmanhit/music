# Offline Music V2

Ứng dụng nghe nhạc offline cho iPhone viết bằng Flutter, giao diện tối lấy cảm hứng từ ảnh tham khảo của người dùng nhưng không sao chép tên, logo hoặc tài sản của ứng dụng khác.

## Chức năng chạy thật

- Nhập nhiều file từ ứng dụng Files: MP3, M4A, MP4 audio, AAC, WAV, FLAC, OGG, OPUS, AIFF.
- Sao chép file vào thư mục riêng của ứng dụng để nghe hoàn toàn offline.
- Đọc title, artist, album, artwork, lyrics, duration, bitrate và sample rate khi file có metadata.
- Trang chủ: Mix hằng ngày, lịch sử nghe, nghe gần đây, yêu thích và tìm kiếm.
- Thư viện: bài hát, playlist, thư mục, nghệ sĩ và album.
- Tạo, đổi tên, xóa playlist; thêm hoặc bỏ bài khỏi playlist.
- Phát nền, màn hình khóa, Control Center, tai nghe, Bluetooth và AirPlay do iOS quản lý.
- Phát/tạm dừng, tua, bài trước/sau, trộn bài, lặp danh sách, lặp một bài.
- Hẹn giờ tắt nhạc và điều chỉnh âm lượng trong ứng dụng.
- Truyền nhiều file từ máy tính qua Wi-Fi bằng trình duyệt, không cần server bên ngoài.
- Chia sẻ thư mục Documents qua Files/Finder nhờ iOS File Sharing.
- GitHub Actions build `Runner.app` không ký rồi đóng gói thành IPA để ký bằng ESign.

## Không giả lập

- EQ đa băng tần và bit-perfect không được gắn nhãn là hoạt động. Hai chức năng này cần audio engine native riêng trên iOS; màn hình Chất lượng nói rõ giới hạn này.
- Ứng dụng không tải nhạc từ Spotify, Apple Music hoặc YouTube.

## Đưa vào repo GitHub có sẵn

1. Giải nén ZIP.
2. Chép toàn bộ file **bên trong** thư mục này vào thư mục repo `offline-music` trên máy.
3. Đảm bảo `pubspec.yaml` nằm ngay ngoài cùng của repo.
4. GitHub Desktop: `Commit to main` → `Push origin`.
5. GitHub: `Actions` → `Build unsigned IPA` → `Run workflow`.
6. Tải artifact `Offline-Music-Unsigned-IPA`, giải nén để lấy `OfflineMusic-unsigned.ipa`.
7. Ký IPA bằng ESign rồi cài lên iPhone.

## Bundle ID

Mặc định: `com.ducmanhit.offlinemusic`

Có thể đổi trong GitHub tại:

`Settings → Secrets and variables → Actions → Variables`

- `BUNDLE_ID=com.tenban.offlinemusic`
- `FLUTTER_ORG=com.tenban`

Không cần certificate hoặc provisioning profile trong GitHub Actions.
