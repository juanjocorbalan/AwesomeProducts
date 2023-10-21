import Foundation
import Combine
import Domain

@MainActor
final class ProductListViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var productsSubject = CurrentValueSubject<[Product], Never>([])
    private let getProductsUseCase: GetProductsUseCase
    private let deleteProductUseCase: DeleteProductUseCase
    weak var flowController: ProductsListFlowControllerProtocol?
    
    // MARK: - Inputs
    
    let productSelected = PassthroughSubject<String, Never>()
    let productDeleted = PassthroughSubject<String, Error>()
    let reload = PassthroughSubject<Void, Error>()
    
    // MARK: - Outputs
    
    @Published private(set) var title = "Awesome Products"
    @Published private(set) var products: [ProductCellViewModel] = []
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isLoading = true

    // MARK: - Init

    init(getProductsUseCase: GetProductsUseCase,
         deleteProductUseCase: DeleteProductUseCase,
         flowController: ProductsListFlowControllerProtocol?
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.deleteProductUseCase = deleteProductUseCase
        self.flowController = flowController
        setupBindings()
    }
    
    // MARK: - Setup

    private func setupBindings() {
        
        Publishers.Merge3(reload.map { _ in true }.assertNoFailure(),
                          $errorMessage.map { _ in false }.assertNoFailure(),
                          $products.map { _ in false }.assertNoFailure())
        .assign(to: \.isLoading, on: self)
        .store(in: &cancellables)
        
        productsSubject
            .map { $0.map { ProductCellViewModel(product: $0) } }
            .assign(to: \.products, on: self)
            .store(in: &cancellables)

        reload
            .map { _ in
                Future { promise in
                    Task {
                        do {
                            let products = try await self.getProductsUseCase.execute()
                            promise(.success(products))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .switchToLatest()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] products in
                self?.productsSubject.send(products)
            })
            .store(in: &cancellables)
        
        productDeleted
            .compactMap { selectedId in return self.productsSubject.value.first(where: { $0.id == selectedId }) }
            .flatMap { product in
                Future { promise in
                    Task {
                        do {
                            try await self.deleteProductUseCase.execute(with: product)
                            promise(.success(product))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] product in
                self?.productsSubject.value.removeAll(where: { $0.id == product.id} )
            })
            .store(in: &cancellables)
        
        productSelected
            .compactMap { selectedId in return self.productsSubject.value.first(where: { $0.id == selectedId }) }
            .sink(receiveValue: { [weak self] product in
                self?.flowController?.showProduct(product)
            })
            .store(in: &cancellables)
    }
}
