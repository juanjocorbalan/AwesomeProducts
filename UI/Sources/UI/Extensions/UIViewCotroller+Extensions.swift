import UIKit

public extension UIViewController {

    var topVisibleViewController: UIViewController {
        if let navigationVC = self as? UINavigationController, let topVC = navigationVC.topViewController {
            return topVC.topVisibleViewController
        }
        if let tabBarVC = self as? UITabBarController, let selectedVC = tabBarVC.selectedViewController {
            return selectedVC.topVisibleViewController
        }
        if let childVC = children.last {
            return childVC.topVisibleViewController
        }
        return self
    }

    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    func addChildViewController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildViewController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
