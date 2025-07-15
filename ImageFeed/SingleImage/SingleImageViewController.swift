import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    var imageURL: URL?
    
    // MARK: - @IBOutlet
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        if let imageURL = imageURL {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    let image = imageResult.image
                    self.imageView.image = image
                    self.imageView.frame.size = image.size
                    self.rescaleAndCenterImageInScrollView(image: image)
                case .failure(let error):
                    print("Ошибка загрузки картинки: \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let imageURL else { return }
        let share = UIActivityViewController(
            activityItems: [imageURL],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(minZoomScale, min(maxZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
