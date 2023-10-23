import UIKit
import Domain
import UI

protocol MainTabFlowControllerProtocol: FlowControllerProtocol { }

class MainTabFlowController: UIViewController {
    private var productsFlowController: ProductsListFlowControllerProtocol!
    private var deletedFlowController: ProductsListFlowControllerProtocol!
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
    
        let flow = parentFlow as? AppFlowControllerProtocol
        productsFlowController = dependencies.resolve(type: .active, parentFlow: flow)
        productsFlowController.tabBarItem = UITabBarItem(title: "Products",
                                                         image: UIImage(systemName: "shippingbox"),
                                                         tag: 1)
        deletedFlowController = dependencies.resolve(type: .deleted, parentFlow: flow)
        deletedFlowController.tabBarItem = UITabBarItem(title: "Deleted",
                                                        image: UIImage(systemName: "trash.slash"),
                                                        tag: 2)
        tabController.viewControllers = [ UINavigationController(rootViewController: productsFlowController),
                                          UINavigationController(rootViewController: deletedFlowController)]
        addChildViewController(tabController)
    }
}

extension MainTabFlowController: MainTabFlowControllerProtocol { }
