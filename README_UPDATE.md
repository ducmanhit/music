# BẢN CẬP NHẬT GIAO DIỆN & CHỨC NĂNG

## 1. Giao Diện Phát Nhạc (UI/UX)
- Chuyển `NowPlayingScreen` sang chế độ cố định màn hình (Không dùng BottomSheet) để tránh lỗi trượt nhầm.
- Thiết kế theo chuẩn Glassmorphism nguyên khối với tone màu xám Titanium sang trọng.
- Loại bỏ hoàn toàn các dải gradient xanh/tím để giữ sự đồng nhất.

## 2. Các Package Mới Cần Cài Đặt (Xem pubspec.yaml)
- `image_picker`, `image_cropper`, `http`: Phục vụ tìm kiếm và sửa ảnh bìa.
- `google_sign_in`, `googleapis`, `aad_oauth`: Xác thực và kết nối Google Drive / OneDrive.
- `flutter_downloader`: Tải nhạc ngầm.

## 3. Hướng Dẫn Tích Hợp
- Ghi đè file `lib/screens/now_playing_screen.dart` vào project hiện tại.
- Cập nhật `pubspec.yaml` và chạy lệnh `flutter pub get`.
