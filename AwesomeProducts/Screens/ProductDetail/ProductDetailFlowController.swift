
import UIKit
import Combine
import Domain
import UI

protocol ProductDetailFlowControllerProtocol: FlowControllerProtocol {}

final class ProductsLDetailFlowController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var product: Product
    let dependencies: DependencyContainer
    let parentFlow: FlowControllerProtocol?

    init(product: Product, dependencies: DependencyContainer, parentFlow: ProductsListFlowControllerProtocol?) {
        self.product = product
        self.dependencies = dependencies
        self.parentFlow = parentFlow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rootViewController: ProductDetailViewController = dependencies.resolve(product: product)
        
        rootViewController.viewModel?.close
            .sink(receiveValue: { [weak self] _ in
                self?.close()
            })
            .store(in: &cancellables)

        addChildViewController(rootViewController)
    }
}

extension ProductsLDetailFlowController: ProductDetailFlowControllerProtocol {
}
