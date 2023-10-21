import UIKit

protocol AppFlowControllerProtocol: FlowControllerProtocol {}

final class AppFlowController: UINavigationController {
    let dependencies: DependencyContainer
    let parentFlow: FlowControllerProtocol?
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        self.parentFlow = nil
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let rootFlow: ProductsListFlowControllerProtocol = dependencies.resolve(parentFlow: self)
        viewControllers = [rootFlow]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppFlowController: AppFlowControllerProtocol {}
