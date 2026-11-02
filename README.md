# VietType

Bộ gõ tiếng Việt cho macOS, hỗ trợ **Telex và VNI**, viết bằng Swift và InputMethodKit. Miễn phí, mã nguồn mở theo giấy phép MIT.

**Trạng thái: beta.** Có trình cài/gỡ với giao diện, bản build universal cho Apple Silicon và Intel, kiểm thử engine, phiên nhập liệu và cài đặt. Bản beta tự động chưa có Developer ID/notarization; xem giới hạn bên dưới trước khi tải.

## Tải và cài

1. Vào [Releases](https://github.com/chiennc-dev/viet-type/releases), chọn bản beta mới nhất và tải `VietType-…-universal.zip`. Đừng chọn “Source code” nếu chỉ muốn cài dùng.
2. Giải nén, mở **VietType Installer.app** và nhấn **Cài đặt VietType**.
3. Mở **System Settings → Keyboard → Text Input → Edit → + → Vietnamese → VietType**. Nếu chưa thấy, đăng xuất và đăng nhập lại rồi thêm bộ gõ.
4. Chọn VietType từ menu Input Sources. Trong menu VietType, chọn **Telex** hoặc **VNI**.

Chỉ cài cho tài khoản hiện tại, không cần `sudo`, Accessibility hay Input Monitoring. Xem [hướng dẫn chi tiết](docs/INSTALL.vi.md), gồm cách cập nhật và gỡ.

### Chữ ký của bản beta

Bản beta tự động được ký **ad hoc**, chưa được Apple notarize. macOS có thể chặn trình cài hoặc bộ gõ tải từ Internet. Việc build thành công và kiểm tra chữ ký ad hoc không có nghĩa là Gatekeeper chấp nhận ứng dụng.

Nếu chọn dùng bản này, làm theo [hướng dẫn mở ứng dụng của Apple](https://support.apple.com/en-gb/102445). Nếu máy do công ty quản lý hoặc macOS tiếp tục chặn, dùng bản tự build từ mã nguồn hoặc chờ bản có Developer ID/notarization. Dự án không tắt Gatekeeper, không tự xóa quarantine và không yêu cầu giảm bảo mật hệ thống.

## Cách gõ

| Chức năng | Telex | VNI |
| --- | --- | --- |
| â, ê, ô | aa, ee, oo | a6, e6, o6 |
| ă | aw | a8 |
| ơ, ư, ươ | ow, uw, uow | o7, u7, uo7 |
| đ | dd | d9 |
| sắc, huyền, hỏi, ngã, nặng | s, f, r, x, j | 1, 2, 3, 4, 5 |
| Bỏ dấu thanh | z | 0 |

`tieengs Vieetj` hoặc `tie6ng1 Vie6t5` → **tiếng Việt**. `dduowngf` hoặc `d9uo7ng2` → **đường**. Hỗ trợ chữ hoa, dấu muộn, các cụm **ươ/ưu/ươu**, cách đặt dấu truyền thống **hòa, khỏe, thúy** và xử lý **qu/gi**.

- **Escape** khôi phục phím gõ của từ đang soạn. Nếu đã Backspace, giữ cách viết sau khi sửa.
- **Backspace** xóa một ký tự hiển thị cùng dấu của nó.
- Space, Enter, dấu câu, điều hướng và Cmd/Control/Option kết thúc từ đang soạn.
- Lặp phím biến đổi để lấy ký tự thường: `aaa` → `aa`, `ass` → `as`, `a66` → `a6`.
- Mặc định, từ không phù hợp cấu trúc âm tiết tiếng Việt được khôi phục phím gõ khi kết thúc từ. Có thể tắt trong menu VietType. Đây là kiểm tra cấu trúc, không phải từ điển hay tự nhận diện tiếng Anh: `as` vẫn có thể thành `á`. Dùng Escape hoặc chuyển Input Source khi nhập tiếng Anh.

## Quyền riêng tư

Engine xử lý tại máy, chỉ giữ từ đang soạn trong bộ nhớ, không ghi nhật ký phím và không gửi nội dung nhập lên mạng. Trình cài không thu thập telemetry; nút hướng dẫn mở trang Releases trong trình duyệt. Xem [PRIVACY.md](PRIVACY.md).

## Build từ mã nguồn

Cần macOS 13+ và Xcode/Command Line Tools có Swift 5.9+.

```bash
git clone https://github.com/chiennc-dev/viet-type.git
cd viet-type
bash scripts/test.sh
bash scripts/build.sh
bash scripts/install.sh
```

Build mặc định cho kiến trúc máy đang dùng. Bản universal và gói ZIP chia sẻ:

```bash
bash scripts/package.sh
```

Sản phẩm ở `dist/`, được bỏ khỏi Git. Cài qua script dùng cùng cơ chế xác minh chữ ký, staging và backup của trình cài giao diện. `bash scripts/uninstall.sh` gỡ về thư mục backup; chuyển sang Input Source khác và bỏ VietType trong Settings trước khi gỡ.

## Phát triển và phát hành

- `Sources/VietTypeCore`: engine, kiểm tra âm tiết và quản lý phiên soạn.
- `Sources/VietTypeIME`: tích hợp InputMethodKit và menu.
- `Sources/VietTypeInstallerCore`: cài/cập nhật/gỡ có backup và xác minh chữ ký.
- `Sources/VietTypeInstaller`: trình cài AppKit.
- `Tests`: kiểm thử nội dung, luồng nhập và cài đặt trên thư mục tạm.
- `.github/workflows`: CI trên ARM và Intel; tag beta tạo GitHub prerelease sau khi kiểm thử đạt.

Xem [kết quả và ma trận kiểm thử](docs/QA.md), [quy trình phát hành có notarization](docs/RELEASING.md) và [CONTRIBUTING.md](CONTRIBUTING.md).

Chưa có gõ tắt, tự cập nhật, từ điển, tự chuyển ngôn ngữ hay sửa lại từ đã kết thúc. Ứng dụng dùng marked text chuẩn của macOS; tương thích TextEdit, trình duyệt, Electron và terminal cần được kiểm chứng riêng. Các ô mật khẩu có thể dùng cơ chế nhập riêng của hệ thống.
