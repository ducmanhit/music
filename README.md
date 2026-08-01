# Offline Music V11

Ứng dụng nghe nhạc offline cho iPhone, viết bằng Flutter.

## V11 – Polished Popups

- Toàn bộ popup, hộp xác nhận, menu hành động và bottom sheet dùng một hệ component thống nhất.
- Tự xử lý Safe Area, Dynamic Island, thanh Home Indicator và bàn phím.
- Giới hạn chiều cao, hỗ trợ cuộn và chống tràn nội dung trên iPhone màn hình nhỏ.
- Popup phẳng, trắng, bo tròn; không gradient, không bóng 3D, không phản chiếu giả.
- Chuyển động mở/đóng ngắn, nhẹ và có phản hồi rung kiểu iOS.
- Menu sắp xếp và menu playlist không còn phụ thuộc PopupMenuButton định vị nổi.
- Hộp nhập tên playlist tự vô hiệu hóa nút lưu khi nội dung trống.
- Hộp xóa dùng màu cảnh báo thống nhất và không chồng route khi mở sau bottom sheet.

## Build IPA chưa ký

Workflow nằm tại `.github/workflows/build-ipa.yml`. Sau khi push lên nhánh `main`, tải artifact IPA và ký bằng ESign.
