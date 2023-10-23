import UIKit
import Domain
import UI

enum ProductsListType: String{
    case active = "Awesome Products"
    case deleted = "Deleted Products"
}

protocol ProductsListFlowControllerProtocol: FlowControllerProtocol {
    func showProduct(_ product: Product) -> Void
}

final class ProductsListFlowController: UIViewController {
    
    private lazy var animator: ZoomAnimator = dependencies.resolve()
    private var rootViewController: ProductListViewController?
    let dependencies: DependencyContainer
    let parentFlow: FlowControllerProtocol?
    let type: ProductsListType

    init(type: ProductsListType, dependencies: DependencyContainer, parentFlow: AppFlowControllerProtocol?) {
        self.dependencies = dependencies
        self.parentFlow = parentFlow
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rootViewController: ProductListViewController = dependencies.resolve(type: type, parentFlow: self)
        self.rootViewController = rootViewController
        self.rootViewController?.hidesBottomBarWhenPushed = true
        addChildViewController(rootViewController)
    }
}

extension ProductsListFlowController: ProductsListFlowControllerProtocol {
    func showProduct(_ product: Product) -> Void {
        switch type {
        case .active:
            let flow: ModalProductDetailFlowControllerProtocol = dependencies.resolve(product: product, parentFlow: self)
            let navigationController = UINavigationController(rootViewController: flow)
            navigationController.transitioningDelegate = animator
            present(screen: navigationController)
        case .deleted:
            let detailVC: ProductDetailViewController = dependencies.resolve(product: product)
            detailVC.hidesBottomBarWhenPushed = true
            push(screen: detailVC)
        }
    }
}
