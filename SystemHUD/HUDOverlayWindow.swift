import UIKit
import WebKit

// Overlay window noi trong PHAM VI CUA CHINH APP NAY.
// Bubble kich thuoc nho (44x44, bang co nut AssistiveTouch cua Apple)
// de khong che thao tac man hinh, tu dong snap sat met trai/phai khi tha ra.
final class HUDOverlayWindow: UIWindow {

    private let bubbleSize: CGFloat = 44
    private var bubbleView: UIView!
    private var webView: WKWebView!
    private var bridge: HUDBridge!
    private var infoProvider = SystemInfoProvider()
    private var pushTimer: Timer?
    private var expanded = false

    private var edgeInset: CGFloat = 6

    func setupBubble() {
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        rootVC.view.isUserInteractionEnabled = true
        self.rootViewController = rootVC

        // --- Bubble tron nho ---
        bubbleView = UIView(frame: CGRect(x: bounds.width - bubbleSize - edgeInset,
                                           y: 140,
                                           width: bubbleSize,
                                           height: bubbleSize))
        bubbleView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bubbleView.layer.cornerRadius = bubbleSize / 2
        bubbleView.layer.borderWidth = 1
        bubbleView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.3
        bubbleView.layer.shadowRadius = 4

        let icon = UILabel(frame: bubbleView.bounds)
        icon.text = "HUD"
        icon.font = .systemFont(ofSize: 9, weight: .bold)
        icon.textAlignment = .center
        icon.textColor = .white
        bubbleView.addSubview(icon)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bubbleView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleExpanded))
        bubbleView.addGestureRecognizer(tap)

        rootVC.view.addSubview(bubbleView)

        // --- Panel HUD (WKWebView) ---
        let panelSize = CGSize(width: 300, height: 220)
        let panelFrame = CGRect(x: (bounds.width - panelSize.width) / 2,
                                 y: (bounds.height - panelSize.height) / 2,
                                 width: panelSize.width,
                                 height: panelSize.height)

        let ucc = WKUserContentController()
        bridge = HUDBridge()
        bridge.owner = self
        ucc.add(bridge, name: "hudBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = ucc

        webView = WKWebView(frame: panelFrame, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.layer.cornerRadius = 18
        webView.layer.masksToBounds = true
        webView.isHidden = true

        if let htmlURL = Bundle.main.url(forResource: "hud", withExtension: "html") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
        rootVC.view.addSubview(webView)

        infoProvider.start()
        pushTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pushStats()
        }
    }

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        guard let container = rootViewController?.view else { return }
        let translation = pan.translation(in: container)
        bubbleView.center = CGPoint(x: bubbleView.center.x + translation.x,
                                     y: bubbleView.center.y + translation.y)
        pan.setTranslation(.zero, in: container)

        if pan.state == .ended {
            snapToEdge()
        }
    }

    // Sau khi tha tay, bubble tu dong dinh sat met man hinh gan nhat
    // de khong che noi dung, giu kich thuoc nho gon (44pt).
    private func snapToEdge() {
        guard let container = rootViewController?.view else { return }
        let screenWidth = container.bounds.width
        let midX = bubbleView.center.x
        let targetX = midX < screenWidth / 2
            ? bubbleSize / 2 + edgeInset
            : screenWidth - bubbleSize / 2 - edgeInset

        var targetY = bubbleView.center.y
        let minY = safeAreaInsets.top + bubbleSize / 2 + 8
        let maxY = container.bounds.height - safeAreaInsets.bottom - bubbleSize / 2 - 8
        targetY = min(max(targetY, minY), maxY)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.bubbleView.center = CGPoint(x: targetX, y: targetY)
        }
    }

    @objc func toggleExpanded() {
        expanded.toggle()
        webView.isHidden = !expanded
        if expanded {
            rootViewController?.view.bringSubviewToFront(webView)
        }
    }

    private func pushStats() {
        guard expanded else { return }
        let stats = infoProvider.snapshot()
        guard let json = try? JSONSerialization.data(withJSONObject: stats),
              let jsonStr = String(data: json, encoding: .utf8) else { return }
        webView.evaluateJavaScript("window.updateStats && window.updateStats(\(jsonStr));")
    }

    func applyFeatureToggle(key: String, enabled: Bool) {
        // TODO: gan hanh dong that cho tung key (vi du: bat/tat dark mode noi bo app,
        // bat/tat 1 tinh nang cua chinh app ban, mo 1 man hinh nhanh...)
        print("[SystemHUD] toggle \(key) -> \(enabled)")
    }
}

// Nhan message tu JS (hud.js) gui len qua window.webkit.messageHandlers.hudBridge
final class HUDBridge: NSObject, WKScriptMessageHandler {
    weak var owner: HUDOverlayWindow?

    func userContentController(_ userContentController: WKUserContentController,
                                didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }

        switch action {
        case "toggleExpand":
            owner?.toggleExpanded()
        case "toggleFeature":
            if let key = body["key"] as? String {
                let enabled = (body["enabled"] as? Bool) ?? false
                owner?.applyFeatureToggle(key: key, enabled: enabled)
            }
        default:
            break
        }
    }
}
