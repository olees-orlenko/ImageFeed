@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.view = viewController
        
        //when
        viewController.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateTableViewAnimatedCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.view = viewController
        
        //when
        viewController.updateTableViewAnimated()
        
        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    func testReloadRowsCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.view = viewController
        
        let testIndexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
        
        //when
        viewController.reloadRows(at: testIndexPaths)
        
        //then
        XCTAssertTrue(viewController.reloadRowsCalled)
        XCTAssertEqual(viewController.reloadRowsIndexPaths, testIndexPaths)
    }
    
    func testDidTapLikeCalled() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        viewController.configure(presenter: presenter)
        presenter.view = viewController
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        //when
        presenter.didTapLike(at: indexPath)
        
        //then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
}
