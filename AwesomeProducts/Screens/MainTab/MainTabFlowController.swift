import UIKit
import Domain
import UI

@MainActor
protocol MainTabFlowControllerProtocol: FlowControllerProtocol { 
    func deleted(product: Product, from type: ProductsListType)
}

class MainTabFlowController: UIViewController {
    private var productsFlowController: ProductsListFlowController!
    private var deletedFlowController: ProductsListFlowController!
    private var tabController: UITabBarController!
    
    let dependencies: DependencyContainer
    let parentFlow: FlowControllerProtocol?

    init(dependencies: DependencyContainer, parentFlow: AppFlowControllerProtocol?) {
        self.dependencies = dependencies
        self.parentFlow = parentFlow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabController = UITabBarController()
    
        productsFlowController = dependencies.resolve(type: .active, parentFlow: self)
        productsFlowController.tabBarItem = UITabBarItem(title: "Products",
                                                         image: UIImage(systemName: "shippingbox"),
                                                         tag: 1)
        deletedFlowController = dependencies.resolve(type: .deleted, parentFlow: self)
        deletedFlowController.tabBarItem = UITabBarItem(title: "Deleted",
                                                        image: UIImage(systemName: "trash.slash"),
                                                        tag: 2)
        tabController.viewControllers = [ UINavigationController(rootViewController: productsFlowController),
                                          UINavigationController(rootViewController: deletedFlowController)]
        addChildViewController(tabController)
    }
}

extension MainTabFlowController: MainTabFlowControllerProtocol { 
    func deleted(product: Product, from type: ProductsListType) {
        switch type {
        case .active:
            deletedFlowController.rootViewController?.viewModel?.reload.send(())
        case .deleted:
            productsFlowController.rootViewController?.viewModel?.reload.send(())
        }
    }
}
