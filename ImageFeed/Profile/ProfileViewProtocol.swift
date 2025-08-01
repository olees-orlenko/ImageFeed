import Foundation

protocol ProfileViewProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfile(profile: Profile)
    func updateAvatar(url: URL?)
    func showLogoutAlert()
}
