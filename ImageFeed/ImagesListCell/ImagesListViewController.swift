import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    var photos: [Photo] = []
    
    // MARK: - Private Properties
    
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
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
                self.updateTableViewAnimated()
            }
        if let token = OAuth2TokenStorage.shared.token {
            imagesListService.fetchPhotosNextPage(token: token) { [weak self] _ in
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let photo = photos[indexPath.row]
            let imageURL = URL(string: photo.largeImageURL)
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
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
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        let photo = photos[indexPath.row]
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
            imageListCell.dateLabel.text = DateFormatter.longStyle.string(from: currentDate)
        }
        imageListCell.photoId = photo.id
        imageListCell.setIsLiked(!photo.isLiked)
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            if !imagesListService.isLoading {
                if let token = OAuth2TokenStorage.shared.token {
                    imagesListService.fetchPhotosNextPage(token: token) { _ in
                    }
                } else {
                    print("Токен отсутствует")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.thumbImageURL) else {
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
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.photos[index].isLiked = !photo.isLiked
                        cell.setIsLiked(!photo.isLiked)
                    }
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Ошибка: \(error)")
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось изменить статус лайка",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
