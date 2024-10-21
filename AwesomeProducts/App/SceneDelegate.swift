import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    lazy var dependencies: DependencyContainer = {
        return !(UIApplication.shared.delegate is AppDelegate) || CommandLine.arguments.contains("-UITests")
        ? MockDependencyContainer()
        : DependencyContainer()
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        if UIApplication.shared.delegate is AppDelegate {
            window?.rootViewController = (dependencies.resolve() as AppFlowControllerProtocol)
        } else {
            window?.rootViewController = UIViewController()
        }
        window?.makeKeyAndVisible()
    }
}
