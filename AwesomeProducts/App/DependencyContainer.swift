import Domain
import Data
import UI

@MainActor
class DependencyContainer {
    private lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack()
    }()

    private lazy var imageCache: ImageCacheType = {
        ImageCache(settings: .defaultSettings)
    }()

    private lazy var imageFetcher: ImageFetcher = {
        ImageFetcher(cache: resolve())
    }()

    private lazy var zoomAnimator: ZoomAnimator = {
        return ZoomAnimator()
    }()

    init() {}

    func resolve() -> AppFlowControllerProtocol {
        return AppFlowController(dependencies: self)
    }
    
    func resolve(parentFlow: AppFlowControllerProtocol?) -> MainTabFlowControllerProtocol {
        return MainTabFlowController(dependencies: self, parentFlow: parentFlow)
    }

    func resolve(type: ProductsListType, parentFlow: MainTabFlowControllerProtocol?) -> ProductsListFlowController {
        return ProductsListFlowController(type: type, dependencies: self, parentFlow: parentFlow)
    }
    
    func resolve(product: Product, parentFlow: ProductsListFlowControllerProtocol?) -> ModalProductDetailFlowControllerProtocol {
        ModalProductsLDetailFlowController(product: product, dependencies: self, parentFlow: parentFlow)
    }
    
    func resolve(type: ProductsListType,
                 parentFlow: ProductsListFlowControllerProtocol) -> ProductListViewController {
        let viewController = ProductListViewController.initFromStoryboard()
        viewController.viewModel = resolve(type: type, parentFlow: parentFlow)
        viewController.imageFetcher = resolve()
        return viewController
    }
    
    func resolve(type: ProductsListType,
                 parentFlow: ProductsListFlowControllerProtocol?) -> ProductListViewModel {
        return ProductListViewModel(type: type,
                                    getProductsUseCase: resolve(type: type),
                                    removeFromListUseCase: resolve(type: type),
                                    flowController: parentFlow)
    }
    
    func resolve(product: Product) -> ProductDetailViewController {
        let viewController = ProductDetailViewController.initFromStoryboard()
        viewController.viewModel = resolve(product: product)
        viewController.imageFetcher = resolve()
        return viewController
    }
    
    func resolve(product: Product) -> ProductDetailViewModel {
        return ProductDetailViewModel(product: product)
    }
    
    func resolve(type: ProductsListType) -> GetProductsUseCaseType {
        switch type {
        case .active:
            return GetProductsUseCase(repository: resolve())
        case .deleted:
            return GetDeletedProductsUseCase(repository: resolve())
        }
    }
    
    func resolve(type: ProductsListType) -> RemoveFromListUseCaseType {
        switch type {
        case .active:
            return DeleteProductUseCase(repository: resolve())
        case .deleted:
            return RestoreProductUseCase(repository: resolve())
        }
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
    
    func resolve() -> APIClientType {
        return APIClient(configuration: .default)
    }
    
    func resolve() -> CoreDataClient<Product> {
        return CoreDataClient<Product>(coreDataStack: resolve())
    }
    
    func resolve() -> CoreDataStack {
        return coreDataStack
    }

    func resolve() -> ImageFetcher {
        return imageFetcher
    }
    
    func resolve() -> ImageCacheType {
        return imageCache
    }
    
    func resolve() -> ZoomAnimator {
        return zoomAnimator
    }
}
