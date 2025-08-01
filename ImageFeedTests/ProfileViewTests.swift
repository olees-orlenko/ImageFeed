@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateProfileAndAvatar() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.updateProfileCalled)
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
    
    func testDidTapLogoutButtonCallsShowLogoutAlert() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.didTapLogoutButton()
        
        //then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testUpdateProfileData() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profile = Profile(username: "Test", name: "Test Name", loginName: "@test", bio: "Test Bio")
        
        //when
        viewController.updateProfile(profile: profile)
        
        //then
        XCTAssertEqual(viewController.username, "Test")
        XCTAssertEqual(viewController.name, "Test Name")
        XCTAssertEqual(viewController.loginName, "@test",)
        XCTAssertEqual(viewController.bio, "Test Bio")
    }
    
    func testUpdateAvatarImageURL() {
        //given
        let viewController = ProfileViewControllerSpy()
        let testURL = URL(string: "https://test.com")
        
        //when
        viewController.updateAvatar(url: testURL)
        
        //then
        XCTAssertEqual(viewController.avatarURL, testURL)
    }
}
