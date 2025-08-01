import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var showLogoutAlertCalled = false
    var username: String?
    var name: String?
    var loginName: String?
    var bio: String?
    var avatarURL: URL?
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func updateProfile(profile: Profile) {
        username = profile.username
        name = profile.name
        loginName = profile.loginName
        bio = profile.bio
    }
    
    func updateAvatar(url: URL?) {
        avatarURL = url
    }
}
