import Foundation
import UIKit
@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
    var photos: [ImageFeed.Photo] = []
    var view: ImagesListViewProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLikeCalled: Bool = false
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func cellWasDisplayed(at indexPath: IndexPath) {
        
    }
    
    func fetchNextPage() {
        
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
