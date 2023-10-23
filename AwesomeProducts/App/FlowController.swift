import UIKit

protocol FlowControllerProtocol: UIViewController {
    var dependencies: DependencyContainer { get }
    var parentFlow: FlowControllerProtocol? { get }

    func push(screen: UIViewController, animated: Bool, resetStack: Bool)
    func present(screen: UIViewController, animated: Bool)
    func popToRoot(animated: Bool)
    func close(animated: Bool)
}

extension FlowControllerProtocol {
    func push(screen: UIViewController, animated: Bool = true, resetStack: Bool = false) {
        if navigationController?.presentedViewController != nil { dismiss(animated: false) }
        if resetStack {
            navigationController?.viewControllers.insert(screen, at: 0)
            navigationController?.popToRootViewController(animated: animated)
        } else {
            navigationController?.pushViewController(screen, animated: animated)
        }
    }
    
    func present(screen: UIViewController, animated: Bool = true) {
        if navigationController?.presentedViewController != nil { dismiss(animated: false) }
        present(screen, animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        navigationController?.popToViewController(self, animated: animated)
    }
    
    func close(animated: Bool = true) {
        if navigationController?.presentingViewController != nil {
            dismiss(animated: animated)
        } else {
            navigationController?.popViewController(animated: animated)
        }
    }
    
    func push(screen: UIViewController) {
        push(screen: screen, animated: true, resetStack: false)
    }

    func present(screen: UIViewController) {
        present(screen: screen, animated: true)
    }

    func popToRoot() {
        popToRoot(animated: true)
    }

    func close() {
        close(animated: true)
    }
}
