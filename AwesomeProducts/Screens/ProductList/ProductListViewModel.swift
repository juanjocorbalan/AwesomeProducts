import Foundation
import Combine
import Domain

@MainActor
final class ProductListViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var productsSubject = CurrentValueSubject<[Product], Never>([])
    private let getProductsUseCase: GetProductsUseCaseType
    private let removeFromListUseCase: RemoveFromListUseCaseType
    private let type: ProductsListType
    weak var flowController: ProductsListFlowControllerProtocol?
    
    // MARK: - Inputs
    
    let productSelected = PassthroughSubject<String, Never>()
    let productDeleted = PassthroughSubject<String, Never>()
    let reload = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    
    @Published private(set) var title: String
    @Published private(set) var products: [ProductCellViewModel] = []
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isLoading = true

    // MARK: - Init

    init(type: ProductsListType,
         getProductsUseCase: GetProductsUseCaseType,
         removeFromListUseCase: RemoveFromListUseCaseType,
         flowController: ProductsListFlowControllerProtocol?
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.removeFromListUseCase = removeFromListUseCase
        self.flowController = flowController
        self.type = type
        self.title = type.rawValue
        setupBindings()
    }
    
    // MARK: - Setup

    private func setupBindings() {
        
        Publishers.Merge3(reload.map { _ in true }.assertNoFailure(),
                          $errorMessage.dropFirst().map { _ in false }.assertNoFailure(),
                          productsSubject.dropFirst().map { _ in false }.assertNoFailure())
        .assign(to: \.isLoading, on: self)
        .store(in: &cancellables)
        
        productsSubject
            .dropFirst()
            .map { $0.map { ProductCellViewModel(product: $0) } }
            .assign(to: \.products, on: self)
            .store(in: &cancellables)

        reload
            .sink(receiveValue: { [ weak self ] _ in
                guard let strongSelf = self else { return }
                Task {
                    do {
                        let products = try await strongSelf.getProductsUseCase.execute()
                        strongSelf.productsSubject.send(products)
                    } catch {
                        strongSelf.errorMessage = error.localizedDescription
                    }
                }
            })
            .store(in: &cancellables)
        
        productDeleted
            .compactMap { selectedId in return self.productsSubject.value.first(where: { $0.id == selectedId }) }
            .sink(receiveValue: { [weak self] product in
                guard let strongSelf = self else { return }
                Task {
                    do {
                        try await strongSelf.removeFromListUseCase.execute(with: product)
                        strongSelf.productsSubject.value.removeAll(where: { $0.id == product.id} )
                        strongSelf.flowController?.deleted(product: product)
                    } catch {
                        strongSelf.errorMessage = error.localizedDescription
                    }
                }
            })
            .store(in: &cancellables)
        
        productSelected
            .compactMap { selectedId in return self.productsSubject.value.first(where: { $0.id == selectedId }) }
            .sink(receiveValue: { [weak self] product in
                self?.flowController?.show(product: product)
            })
            .store(in: &cancellables)
    }
}
