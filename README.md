# Offline Music V3

Ứng dụng nghe nhạc offline cho iPhone viết bằng Flutter. Bản V3 nâng cấp giao diện phát nhạc cố định, chỉnh sửa ảnh bìa và nhập file từ các nhà cung cấp đám mây thông qua ứng dụng Files của iOS.

## Chức năng

- Nhập nhiều file: MP3, M4A, MP4 audio, AAC, WAV, FLAC, OGG, OPUS và AIFF.
- Nhập từ bộ nhớ iPhone, iCloud Drive, Google Drive và OneDrive qua trình chọn file của iOS.
- Sao chép file vào bộ nhớ riêng của ứng dụng để nghe hoàn toàn offline.
- Đọc title, artist, album, artwork, lyrics, duration, bitrate và sample rate khi file có metadata.
- Sửa tên bài hát, nghệ sĩ và album trong thư viện ứng dụng.
- Đổi ảnh bìa từ Photos hoặc Files; xóa ảnh bìa tùy chỉnh.
- Tìm ảnh bìa online theo tên bài hát/nghệ sĩ bằng MusicBrainz và Cover Art Archive.
- Trang chủ: Mix hằng ngày, lịch sử nghe, nghe gần đây, yêu thích và tìm kiếm.
- Thư viện: bài hát, playlist, thư mục, nghệ sĩ và album.
- Tạo, đổi tên, xóa playlist; thêm hoặc bỏ bài khỏi playlist.
- Phát nền, màn hình khóa, Control Center, tai nghe, Bluetooth và AirPlay do iOS quản lý.
- Phát/tạm dừng, tua, bài trước/sau, trộn bài, lặp danh sách, lặp một bài.
- Màn hình đang phát dùng bố cục cố định, tự co ảnh bìa theo chiều cao máy và không bị trượt cụm điều khiển xuống dưới.
- Hẹn giờ tắt nhạc và điều chỉnh âm lượng trong ứng dụng.
- GitHub Actions build `Runner.app` không ký rồi đóng gói thành IPA để ký bằng ESign.

## Google Drive và OneDrive

App không cần đăng nhập OAuth riêng. Trên iPhone:

1. Cài Google Drive hoặc Microsoft OneDrive.
2. Mở **Files → Duyệt → dấu ba chấm → Sửa**.
3. Bật Google Drive hoặc OneDrive.
4. Trong app chọn **Thêm nhạc → Google Drive/OneDrive**, sau đó chọn file.

File được iOS cung cấp cho app và được sao chép vào bộ nhớ Offline Music. Sau khi nhập xong, bài hát vẫn nghe offline.

## Ảnh bìa online

Tìm kiếm ảnh bìa chỉ chạy khi người dùng chủ động bấm tìm. Dữ liệu tên phát hành/nghệ sĩ đến từ MusicBrainz và ảnh đến từ Cover Art Archive. Ảnh đã chọn được lưu trong ứng dụng.

## Không giả lập

- EQ đa băng tần và bit-perfect không được gắn nhãn là hoạt động. Hai chức năng này cần audio engine native riêng trên iOS.
- Ứng dụng không tải nhạc từ Spotify, Apple Music hoặc YouTube.

## Đưa bản nâng cấp vào repo GitHub

1. Giải nén ZIP.
2. Chép toàn bộ file **bên trong** vào thư mục repo `music` trên máy và chọn ghi đè.
3. Đảm bảo `pubspec.yaml` nằm ngay ngoài cùng của repo.
4. GitHub Desktop: `Commit to main` → `Push origin`.
5. GitHub Actions sẽ tự chạy. Nếu chưa chạy, chọn `Build unsigned IPA` → `Run workflow`.
6. Tải artifact `Offline-Music-Unsigned-IPA`, giải nén để lấy `OfflineMusic-unsigned.ipa`.
7. Ký IPA bằng ESign rồi cài lên iPhone.

## Bundle ID

Mặc định: `com.ducmanhit.offlinemusic`

Có thể đổi bằng GitHub Actions Variables:

- `BUNDLE_ID=com.tenban.offlinemusic`
- `FLUTTER_ORG=com.tenban`

Không cần certificate hoặc provisioning profile trong GitHub Actions.
