import UIKit
import Domain
import UI

protocol ProductsListFlowControllerProtocol: FlowControllerProtocol {
    func showProduct(_ product: Product) -> Void
}

final class ProductsListFlowController: UIViewController {
    private lazy var animator: ZoomAnimator = dependencies.resolve()
    let dependencies: DependencyContainer
    let parentFlow: FlowControllerProtocol?

    init(dependencies: DependencyContainer, parentFlow: ProductsListFlowControllerProtocol?) {
        self.dependencies = dependencies
        self.parentFlow = parentFlow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rootViewController: ProductListViewController = dependencies.resolve(parentFlow: self)
        
        addChildViewController(rootViewController)
    }
}

extension ProductsListFlowController: ProductsListFlowControllerProtocol {
    func showProduct(_ product: Product) -> Void {
        let flow: ProductDetailFlowControllerProtocol = dependencies.resolve(product: product, parentFlow: self)
        let navigationController = UINavigationController(rootViewController: flow)
        navigationController.transitioningDelegate = animator
        present(screen: navigationController)
    }
}
