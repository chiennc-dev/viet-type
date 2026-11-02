VietType cho macOS 13+, hỗ trợ Telex và VNI. Gói universal dành cho cả Intel và Apple Silicon.

**Đây là bản beta, ký ad hoc, chưa được Apple notarize.** macOS có thể chặn trình cài hoặc bộ gõ tải từ Internet. Chưa cam kết tương thích mọi ứng dụng; xem ma trận kiểm thử trong repository.

### Cài đặt

1. Tải `VietType-…-universal.zip` và giải nén.
2. Mở `VietType Installer.app`, nhấn **Cài đặt VietType**.
3. Đăng xuất/đăng nhập lại nếu chưa thấy bộ gõ.
4. Mở **Settings → Keyboard → Text Input → Edit → + → Vietnamese → VietType**.
5. Chọn Telex/VNI từ menu bộ gõ.

Nếu macOS chặn bản beta, xem [hướng dẫn của Apple](https://support.apple.com/en-gb/102445). Nếu vẫn không mở được, build từ source hoặc chờ bản notarized; không cần tắt bảo mật hệ thống.

### Có trong bản này

- Engine Unicode, chữ hoa, dấu muộn, qu/gi, các cụm ươ/ưu/ươu.
- Khôi phục từ không phù hợp cấu trúc âm tiết khi kết thúc từ; Escape khôi phục thủ công.
- Cài/cập nhật/gỡ với xác minh chữ ký, staging và backup.
- Giới hạn bộ đệm soạn để tránh chậm với chuỗi rất dài.
- Kiểm thử engine, phiên soạn và cài đặt; CI trên ARM và Intel.

### Giới hạn

Chưa có từ điển, tự nhận diện ngôn ngữ, gõ tắt, tự cập nhật hay sửa lại từ đã kết thúc. Tương thích từng ứng dụng và Gatekeeper trên máy mới cần được thử riêng. Không tự thu thập nội dung gõ hay telemetry.

File `.sha256` dùng để kiểm tra ZIP. Gỡ qua trình cài sau khi chuyển sang Input Source khác và bỏ VietType trong Settings.
