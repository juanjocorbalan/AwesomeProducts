import Domain
import Data
import UI

class DependencyContainer {
    private(set) static var shared = DependencyContainer()
    
    init() {}
    
    func resolve() -> AppFlowControllerProtocol {
        return AppFlowController(dependencies: self)
    }
    
    func resolve(parentFlow: AppFlowControllerProtocol?) -> ProductsListFlowControllerProtocol {
        return ProductsListFlowController(dependencies: self, parentFlow: parentFlow)
    }
    
    func resolve(product: Product, parentFlow: ProductsListFlowControllerProtocol?) -> ProductDetailFlowControllerProtocol {
        ProductsLDetailFlowController(product: product, dependencies: self, parentFlow: parentFlow)
    }
    
    @MainActor
    func resolve(parentFlow: ProductsListFlowControllerProtocol) -> ProductListViewController {
        let viewController = ProductListViewController.initFromStoryboard()
        viewController.viewModel = resolve(parentFlow: parentFlow)
        return viewController
    }
    
    @MainActor
    func resolve(parentFlow: ProductsListFlowControllerProtocol?) -> ProductListViewModel {
        return ProductListViewModel(getProductsUseCase: resolve(),
                                    deleteProductUseCase: resolve(),
                                    flowController: parentFlow)
    }
    
    @MainActor
    func resolve(product: Product) -> ProductDetailViewController {
        let viewController = ProductDetailViewController.initFromStoryboard()
        viewController.viewModel = resolve(product: product)
        viewController.imageFetcher = resolve()
        return viewController
    }
    
    @MainActor
    func resolve(product: Product) -> ProductDetailViewModel {
        return ProductDetailViewModel(product: product)
    }
    
    func resolve() -> GetProductsUseCase {
        return GetProductsUseCase(repository: resolve())
    }
    
    func resolve() -> DeleteProductUseCase {
        return DeleteProductUseCase(repository: resolve())
    }
    
    func resolve() -> ProductsRepositoryType {
        return ProductsRepository(apiDataSource: resolve(), cacheDataSource: resolve())
    }
    
    func resolve() -> ProductsAPIDataSourceType {
        return ProductsAPIDataSource(apiClient: resolve())
    }
    
    func resolve() -> ProductsCacheDataSourceType {
        return ProductsCacheDataSource(cacheClient: resolve())
    }
    
    func resolve() -> APIClient {
        return APIClient(configuration: .default)
    }
    
    func resolve() -> CoreDataClient<Product> {
        return CoreDataClient<Product>(coreDataStack: resolve())
    }
    
    func resolve() -> CoreDataStack {
        return CoreDataStack.shared
    }
    
    func resolve() -> ImageFetcher {
        return ImageFetcher.shared
    }
    
    func resolve() -> ZoomAnimator {
        return ZoomAnimator()
    }
}
