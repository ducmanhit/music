# Offline Music V10 — Flat Clear iOS

Ứng dụng nghe nhạc offline bằng Flutter, đóng gói IPA chưa ký qua GitHub Actions.

## Giao diện V10

- Thanh điều hướng dưới trong suốt hơn, blur cao nhưng gần như không phủ màu.
- Tab được chọn dùng nền xanh rất nhạt dạng phẳng, không dùng thấu kính nổi.
- Toàn bộ card và bảng thông tin bỏ bóng, phản chiếu cạnh và hiệu ứng 3D.
- Nút tròn, ảnh bìa, mini player và popup sử dụng bề mặt phẳng, bo góc mềm.
- Không có gradient đen/trắng, neon hoặc bóng nổi.
- Giữ nguyên các chức năng nghe nhạc, sửa ảnh bìa và tìm ảnh bìa online.

## Build IPA

Vào GitHub Actions và chạy workflow `Build iOS unsigned IPA`. Artifact tạo ra chứa IPA chưa ký để ký bằng ESign.
