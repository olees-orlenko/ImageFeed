import Foundation
import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func didTapLike(at indexPath: IndexPath)
    func cellWasDisplayed(at indexPath: IndexPath)
    func fetchNextPage()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private let imagesListService = ImagesListService.shared
    weak var view: ImagesListViewProtocol?
    var photos: [Photo] {
        return imagesListService.photos
    }
    
    func viewDidLoad() {
        fetchNextPage()
    }
    
    func cellWasDisplayed(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            fetchNextPage()
        }
    }

    func fetchNextPage() {
        if !imagesListService.isLoading {
            if let token = OAuth2TokenStorage.shared.token {
                imagesListService.fetchPhotosNextPage(token: token) { _ in
                }
            } else {
                print("Токен отсутствует")
            }
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    UIBlockingProgressHUD.dismiss()
                    return
                }
                switch result {
                case .success:
                    self.view?.reloadRows(at: [indexPath])
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
                    self.view?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
