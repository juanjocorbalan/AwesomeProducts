import UIKit
import Combine
import UI

final class ProductCellView: UICollectionViewCell, StoryboardIdentifiable {
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var thumbnailImageview: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var removeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        thumbnailImageview.image = nil
        thumbnailImageview.alpha = 0.0
        backgroundImageView.image = nil
        backgroundImageView.alpha = 0.0
        productLabel.text = nil
        brandLabel.text = nil
        accessibilityIdentifier = "collectionCellProduct"
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle || traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory
        else { return }
        setupUI()
    }
    
    func setup(with viewModel: ProductCellViewModel, imageFetcher: ImageFetcher = ImageFetcher.shared) {
    
        setupUI()
        
        viewModel.$avatar
            .filter { $0 != nil }
            .flatMap { url in
                Future<UIImage?, Error> { promise in
                    Task {
                        do {
                            let image = try await imageFetcher.fetchImage(from: url!)
                            promise(.success(image))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let strongSelf = self else { return }
                strongSelf.showImage(image: image, in: strongSelf.thumbnailImageview)
            })
            .store(in: &cancellables)

        viewModel.$background
            .filter { $0 != nil }
            .flatMap { url in
                Future<UIImage?, Error> { promise in
                    Task {
                        do {
                            let image = try await imageFetcher.fetchImage(from: url!)
                            promise(.success(image))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let strongSelf = self else { return }
                strongSelf.showImage(image: image, in: strongSelf.backgroundImageView)
            })
            .store(in: &cancellables)

        viewModel.$name
            .map { $0 }
            .assign(to: \.text, on: productLabel)
            .store(in: &cancellables)
        
        viewModel.$city
            .map { $0 }
            .assign(to: \.text, on: brandLabel)
            .store(in: &cancellables)
    
        removeButton.addAction(UIAction() { _ in
            viewModel.removeSelected.send(())
        }, for: .touchUpInside)
    }
    
    private func setupUI() {
        productLabel.font = UIFont.preferredFont(forTextStyle: .body)
        brandLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        thumbnailImageview.layer.cornerRadius = Styles.CornerRadius.regular
        thumbnailImageview.layer.masksToBounds = true
        thumbnailImageview.layer.borderWidth = Styles.BorderWidth.thumbnail
        thumbnailImageview.layer.borderColor = Styles.Colors.accentColor.cgColor
        containerView.layer.cornerRadius = Styles.CornerRadius.regular
        containerView.layer.masksToBounds = true
        blurView.layer.cornerRadius = Styles.CornerRadius.regular
        blurView.layer.masksToBounds = true
        containerView.layer.borderColor = Styles.Colors.accentColor.cgColor
        containerView.layer.borderWidth = Styles.BorderWidth.product
        removeButton.tintColor = Styles.Colors.accentColor
    }
    
    private func showImage(image: UIImage?, in imageView: UIImageView) {
        imageView.alpha = 0.0
        imageView.image = image
        let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            imageView.alpha = 1.0
        })
        animator.startAnimation()
    }
}
