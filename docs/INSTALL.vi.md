# Cài VietType

Yêu cầu macOS 13 trở lên. Một gói universal dùng cho cả Apple Silicon và Intel.

## Bản tải sẵn

Tải ZIP universal từ https://github.com/chiennc-dev/viet-type/releases, giải nén và mở **VietType Installer.app**. Nhấn **Cài đặt VietType**, sau đó **Mở cài đặt bàn phím**.

Thêm VietType ở **Keyboard → Text Input → Edit → + → Vietnamese**. Có thể cần đăng xuất/đăng nhập lại trước khi bộ gõ xuất hiện. Bật menu Input Sources trên thanh menu để chọn VietType và chọn Telex/VNI. Dùng phím chuyển Input Source đã cấu hình trên máy để đổi sang bộ gõ tiếng Anh.

Bản beta tự động chưa có Developer ID và chưa notarize. macOS có thể chặn ứng dụng tải từ Internet, kể cả bộ gõ bên trong gói cài. Nếu muốn tiếp tục với bản beta, xem cách cho phép từng ứng dụng theo hướng dẫn Apple: https://support.apple.com/en-gb/102445. Nếu vẫn bị chặn, hãy build từ source hoặc chờ bản notarized. Không cần tắt Gatekeeper hoặc gỡ quarantine bằng Terminal.

## Cập nhật

Chuyển sang bộ gõ khác, mở trình cài của bản mới rồi nhấn **Cập nhật VietType**. Trình cài xác minh gói trước khi thay thế; bản cũ nằm trong `~/Library/Application Support/VietType/Backups`. Đăng xuất/đăng nhập lại để dừng tiến trình bộ gõ cũ và dùng phiên bản mới.

## Gỡ và khôi phục

1. Chuyển sang Input Source khác.
2. Bỏ VietType trong **Keyboard → Text Input → Edit**.
3. Mở **VietType Installer.app → Gỡ VietType…** và xác nhận.
4. Đăng xuất/đăng nhập lại.

Trình cài chuyển ứng dụng vào thư mục backup, không xóa hẳn. Muốn khôi phục, chọn bản phù hợp trong `~/Library/Application Support/VietType/Backups`, chép `VietType.app` về `~/Library/Input Methods` khi đang dùng bộ gõ khác, rồi đăng xuất/đăng nhập lại. Có thể xóa backup thủ công sau khi không còn cần.

## Không thấy hoặc không gõ được

- Kiểm tra file tồn tại ở `~/Library/Input Methods/VietType.app`.
- Đăng xuất/đăng nhập lại và kiểm tra danh sách ngôn ngữ Vietnamese hoặc Others.
- Thử một tài liệu mới trong TextEdit với VietType đã được chọn.
- Nếu ô mật khẩu hoặc một ứng dụng cụ thể không nhận bộ gõ, chuyển về bộ gõ hệ thống.
- Gửi issue với macOS, kiến trúc máy, phiên bản VietType, tên/phiên bản ứng dụng và một chuỗi gõ mẫu không nhạy cảm. Không gửi mật khẩu hoặc dữ liệu cá nhân.

## Kiểm tra file tải

Release có file `.sha256` đi kèm ZIP. Trong Terminal, chuyển tới thư mục tải và chạy:

```bash
shasum -a 256 -c VietType-0.1.0-beta.1-universal.zip.sha256
```

Checksum giúp phát hiện lỗi hoặc thay đổi file, không thay thế chữ ký Developer ID/notarization.
