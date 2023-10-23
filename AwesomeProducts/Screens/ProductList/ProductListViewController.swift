import UIKit
import Combine
import UI

final class ProductListViewController: UIViewController, StoryboardInitializable {
    var viewModel: ProductListViewModel?
    var imageFetcher: ImageFetcher?
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()
    private var selectedProductFrame: CGRect?

    // MARK: - DiffableDataSource / Compositional layout
    
    fileprivate enum Section: CaseIterable {
        case main
    }

    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductCellViewModel>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProductCellViewModel>

    fileprivate lazy var dataSource = {
        return DataSource(collectionView: collectionView, cellProvider: { [ imageFetcher ] (collectionView, indexPath, cellViewModel) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCellView.storyboardIdentifier, for: indexPath) as? ProductCellView
                else { return UICollectionViewCell() }
            cellViewModel.removeSelected
                .sink(receiveValue: { [weak self] _ in
                    self?.viewModel?.productDeleted.send(cellViewModel.id)
                })
                .store(in: &cell.cancellables)
            cell.setup(with: cellViewModel, imageFetcher: imageFetcher)
            cell.accessibilityIdentifier = "collectionCellProduct"
            return cell
        })
    }()
    
    fileprivate func createSnapshot(with products: [ProductCellViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(products)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func createLayout() -> UICollectionViewLayout {
        let spacing = Styles.Paddings.list

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let itemWidth = itemSize.widthDimension.dimension * Styles.Layout.productAspectRatio
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(itemWidth))
        let group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        }
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()

        viewModel?.reload.send(())
    }
    
    private func setupUI() {
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.accessibilityIdentifier = "collectionViewProducts"
    }
    
    private func setupBindings() {
        
        title = viewModel?.title
        parent?.navigationItem.title = viewModel?.title

        viewModel?.$products
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] products in
                self?.createSnapshot(with: products)
            })
            .store(in: &cancellables)

        viewModel?.$errorMessage
            .filter { $0 != nil }
            .sink(receiveValue: { [weak self] message in
                self?.refreshControl.endRefreshing()
                self?.showError(message: message!)
            })
            .store(in: &cancellables)

        viewModel?.$isLoading
            .map { !$0 || self.refreshControl.isRefreshing }
            .sink(receiveValue: { [weak self] shouldHide in
                self?.loadingView.isHidden = shouldHide
            })
            .store(in: &cancellables)
        
        refreshControl.addAction(UIAction() { [ weak self ] _ in
            self?.viewModel?.reload.send(())
        }, for: .valueChanged)
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let productId = dataSource.itemIdentifier(for: indexPath)?.id else { return }
        if let cell = collectionView.cellForItem(at: indexPath) {
            selectedProductFrame = cell.contentView.convert(cell.contentView.frame, to: view)
        }
        viewModel?.productSelected.send(productId)
    }
}

extension ProductListViewController: Zoomable {
    var zoomableViewFrame: CGRect {
        selectedProductFrame ?? .zero
    }
}
