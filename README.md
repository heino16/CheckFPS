# SystemHUD App (.ipa thường – không cần jailbreak)

App iOS bình thường, có bubble nhỏ (44pt, cỡ như AssistiveTouch) nổi **trong phạm vi
chính app này**, kéo thả tự do và tự snap sát mép màn hình. Chạm vào bubble mở bảng
HUD hiển thị **FPS / Pin / RAM** cập nhật mỗi giây, cùng **menu tiện ích bật/tắt nhanh**.
Giao diện bảng HUD viết bằng HTML/CSS/JS, hiển thị qua WKWebView; phần đọc dữ liệu hệ
thống và tạo cửa sổ nổi viết bằng Swift.

> Lưu ý quan trọng: bubble chỉ nổi **trong lúc bạn đang dùng app này**. Thoát hẳn ra
> Home hoặc mở app khác thì bubble biến mất — đây là giới hạn cứng của iOS đối với
> app thường (không jailbreak), không có cách nào vượt qua.

## Cấu trúc

```
SystemHUD-App/
└── SystemHUD/
    ├── SystemHUDApp.swift        # entry point, gắn overlay window vào scene
    ├── ContentView.swift          # màn hình chính (placeholder)
    ├── HUDOverlayWindow.swift     # bubble + panel WKWebView, kéo thả, snap mép
    ├── SystemInfoProvider.swift   # đọc FPS / pin / RAM
    └── Resources/
        ├── hud.html
        ├── hud.css
        └── hud.js
```

## Cách tạo project Xcode và nhúng code

1. Mở Xcode → **File > New > Project > iOS > App**
   - Product Name: `SystemHUD`
   - Interface: **SwiftUI**
   - Language: **Swift**
2. Xóa file `ContentView.swift` mặc định Xcode tạo, kéo toàn bộ các file trong
   thư mục `SystemHUD/` (đã cung cấp) vào project, chọn **"Copy items if needed"**.
3. Với 3 file trong `Resources/` (`hud.html`, `hud.css`, `hud.js`):
   - Kéo vào Xcode, đảm bảo tick **"Add to target: SystemHUD"**
   - Kiểm tra trong **Build Phases > Copy Bundle Resources** đã có đủ 3 file này
     (Xcode thường tự thêm khi kéo vào, nhưng nên kiểm tra lại).
4. Trong `Info.plist` hoặc **Signing & Capabilities**, không cần thêm quyền đặc biệt
   nào — app này không dùng API nhạy cảm nào ngoài `UIDevice.batteryMonitoringEnabled`.
5. Chọn thiết bị thật (hoặc simulator để test giao diện, lưu ý pin/RAM trên
   simulator sẽ không chính xác), nhấn **Run**.

## Build ra file .ipa để sideload

```bash
# Archive
xcodebuild -scheme SystemHUD -configuration Release archive \
  -archivePath build/SystemHUD.xcarchive

# Export .ipa (cần file ExportOptions.plist tương ứng phương thức ký của bạn)
xcodebuild -exportArchive \
  -archivePath build/SystemHUD.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

File `.ipa` xuất ra dùng để cài qua **AltStore**, **Sideloadly**, **TrollStore**
(nếu máy hỗ trợ), hoặc cài trực tiếp qua Xcode khi cắm dây.

## Tùy chỉnh

- Đổi giao diện HUD: sửa `hud.html` / `hud.css` / `hud.js`, không cần build lại
  phần Swift.
- Đổi kích thước bubble: sửa hằng số `bubbleSize` trong `HUDOverlayWindow.swift`
  (đang để `44` — bằng đúng cỡ AssistiveTouch mặc định của Apple để không che tay).
- Gán hành động thật cho các toggle: sửa hàm
  `applyFeatureToggle(key:enabled:)` trong `HUDOverlayWindow.swift`.

## Đưa lên GitHub

```bash
cd SystemHUD-App
git init
git add .
git commit -m "SystemHUD app: floating in-app bubble HUD (FPS/battery/RAM + quick toggles)"
git branch -M main
git remote add origin https://github.com/<ten-ban>/SystemHUD-App.git
git push -u origin main
```
