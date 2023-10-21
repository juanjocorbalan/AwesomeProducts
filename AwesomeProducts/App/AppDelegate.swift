import UIKit
import UI

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        return true
    }
    
    private func setupAppearance() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = Styles.Colors.accentColor
        navigationBarAppearace.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Styles.Colors.accentColor
        ]
        
        UIActivityIndicatorView.appearance().color = Styles.Colors.accentColor
        UIRefreshControl.appearance().tintColor = Styles.Colors.accentColor
    }
}
