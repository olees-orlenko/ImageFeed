import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewProtocol?
    var viewDidLoadCalled: Bool = false
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        updateProfileCalled = true
        updateAvatarCalled = true
    }
    
    func didTapLogoutButton() {
        
    }
    
    func updateAvatar() {
        
    }
}
