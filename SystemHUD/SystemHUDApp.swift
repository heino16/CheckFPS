import SwiftUI

@main
struct SystemHUDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// AppDelegate dung de gan them 1 UIWindow phu (overlay) vao cung scene
// voi window chinh cua app -> bubble se noi de tren MOI man hinh trong app,
// nhung van nam trong tien trinh cua chinh app nay (khong the noi ra ngoai app khac).
class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {

    var overlayWindow: HUDOverlayWindow?

    func application(_ application: UIApplication,
                      configurationForConnecting connectingSceneSession: UISceneSession,
                      options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var overlayWindow: HUDOverlayWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Tao overlay window noi tren cung, gan vao scene hien tai cua app
        let overlay = HUDOverlayWindow(windowScene: windowScene)
        overlay.windowLevel = .alert + 1
        overlay.backgroundColor = .clear
        overlay.isHidden = false
        overlay.isUserInteractionEnabled = true
        self.overlayWindow = overlay
        overlay.setupBubble()
    }
}
