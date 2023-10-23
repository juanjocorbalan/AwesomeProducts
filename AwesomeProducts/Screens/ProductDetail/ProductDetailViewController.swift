import UIKit
import UI

final class ProductDetailViewController: UIViewController, StoryboardInitializable {
    var viewModel: ProductDetailViewModel?
    var imageFetcher: ImageFetcher?
    
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
            self?.viewModel?.close.send(())
        })
    }
    
    private func setupBindings() {
        if let thubnailURL = viewModel?.thumbnail {
            Task {
                let image = try await imageFetcher?.fetchImage(from: thubnailURL)
                showImage(image: image, in: thumbnailImageView)
            }
        }

        if let backgroundURL = viewModel?.background {
            Task {
                let image = try await imageFetcher?.fetchImage(from: backgroundURL)
                showImage(image: image, in: backgroundImageView)
            }
        }
        
        title = viewModel?.name
        parent?.title = viewModel?.name
        
        brandLabel.text = viewModel?.brand
        
        categoryLabel.text = viewModel?.category
        
        descriptionTextView.text = viewModel?.text
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
