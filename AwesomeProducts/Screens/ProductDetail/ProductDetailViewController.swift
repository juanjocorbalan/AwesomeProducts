import UIKit
import Combine
import UI

final class ProductDetailViewController: UIViewController, StoryboardInitializable {
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: ProductDetailViewModel!
    var imageFetcher: ImageFetcher!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var blurView1: UIVisualEffectView!
    @IBOutlet weak var blurView2: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        navigationController?.presentationController?.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle || traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory
        else { return }
        setupUI()
    }
 
    private func setupUI() {
        brandLabel.font = UIFont.preferredFont(forTextStyle: .body)
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionTextView.font = UIFont.preferredFont(forTextStyle: .body)
        thumbnailImageView.alpha = backgroundImageView.image == nil ? 0.0 : 1.0
        thumbnailImageView.layer.cornerRadius = Styles.CornerRadius.regular
        thumbnailImageView.layer.masksToBounds = true
        thumbnailImageView.layer.borderWidth = Styles.BorderWidth.thumbnail
        thumbnailImageView.layer.borderColor = Styles.Colors.accentColor.cgColor
        descriptionTextView.textContainerInset = .zero
        blurView1.layer.cornerRadius = Styles.CornerRadius.regular
        blurView1.layer.masksToBounds = true
        blurView1.layer.borderWidth = Styles.BorderWidth.product
        blurView1.layer.borderColor = Styles.Colors.accentColor.cgColor
        blurView2.layer.cornerRadius = Styles.CornerRadius.regular
        blurView2.layer.masksToBounds = true
        blurView2.layer.borderWidth = Styles.BorderWidth.product
        blurView2.layer.borderColor = Styles.Colors.accentColor.cgColor
        backgroundImageView.alpha = backgroundImageView.image == nil ? 0.0 : 1.0
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .stop,
                                                                    primaryAction: UIAction() { [ weak self ] _ in
            self?.viewModel.close.send(())
        })
    }
    
    private func setupBindings() {
        viewModel.$thumbnail
            .compactMap { $0 }
            .flatMap { [ weak self ] url in
                Future<UIImage?, Error> { promise in
                    Task {
                        do {
                            let image = try await self?.imageFetcher.fetchImage(from: url)
                            promise(.success(image))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let strongSelf = self else { return }
                strongSelf.showImage(image: image, in: strongSelf.thumbnailImageView)
            })
            .store(in: &cancellables)
        
        viewModel.$background
            .compactMap { $0 }
            .flatMap { [ weak self ] url in
                Future<UIImage?, Error> { promise in
                    Task {
                        do {
                            let image = try await self?.imageFetcher.fetchImage(from: url)
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
            .sink(receiveValue: { [ weak self] title in
                self?.parent?.navigationItem.title = title
                self?.navigationItem.title = title
            })
            .store(in: &cancellables)
        
        viewModel.$brand
            .map { $0 }
            .assign(to: \.text, on: brandLabel)
            .store(in: &cancellables)
        
        viewModel.$category
            .map { $0 }
            .assign(to: \.text, on: categoryLabel)
            .store(in: &cancellables)
        
        viewModel.$text
            .map { $0 }
            .assign(to: \.text, on: descriptionTextView)
            .store(in: &cancellables)
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

extension ProductDetailViewController: UIAdaptivePresentationControllerDelegate {}
