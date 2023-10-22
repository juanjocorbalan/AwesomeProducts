import UIKit
import UI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var dependencies: DependencyContainer!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)

        if let _ = UIApplication.shared.delegate as? AppDelegate {
            if CommandLine.arguments.contains("-UITests") {
                let mockedDependencies = MockDependencyContainer()
                dependencies = mockedDependencies
                mockedDependencies.setUp()
            } else {
                dependencies = DependencyContainer.shared
            }
            window?.rootViewController = (dependencies.resolve() as AppFlowControllerProtocol)
        } else {
            dependencies = MockDependencyContainer()
            window?.rootViewController = UIViewController()
        }
        
        window?.makeKeyAndVisible()
    }
}
