import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    // MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListServiceObserver: NSObjectProtocol?
    
    // MARK: - @IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.view?.updateTableViewAnimated()
            }
        presenter?.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let photo = presenter?.photos[indexPath.row]
            let imageURL = URL(string: photo?.largeImageURL ?? "")
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    
    func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = presenter?.photos.count ?? 0
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
}

// MARK: - DateFormatter

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        guard let presenter = presenter else {
            return imageListCell
        }
        guard indexPath.row < presenter.photos.count else {
            return imageListCell
        }
        imageListCell.delegate = self
        let photo = presenter.photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)
        imageListCell.cellImage.kf.indicatorType = .activity
        imageListCell.task = imageListCell.cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub"),
            options: [.transition(.fade(0.2))],
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Ошибка загрузки картинки: \(error)")
                }
            }
        )
        if let createdAt = photo.createdAt {
            imageListCell.dateLabel.text = DateFormatter.longStyle.string(from: createdAt)
        } else {
            imageListCell.dateLabel.text = ""
        }
        imageListCell.photoId = photo.id
        imageListCell.setIsLiked(photo.isLiked)
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.cellWasDisplayed(at: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row] else {
            return 0
        }
        let imageTopBottomInset: CGFloat = 4
        let imageLeftRightInset: CGFloat = 16
        let imageWidth = CGFloat(photo.size.width)
        let imageHeight = CGFloat(photo.size.height)
        let imageViewWidth = tableView.bounds.width - imageLeftRightInset - imageLeftRightInset
        let imageScale = imageViewWidth / imageWidth
        let imageViewHeight = imageHeight * imageScale
        return imageViewHeight + imageTopBottomInset + imageTopBottomInset
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
