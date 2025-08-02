import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func updateAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: ProfileViewProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        updateProfile()
        updateAvatar()
    }
    
    // MARK: - Actions
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
    
    // MARK: - Private Methods
    
    private func updateProfile() {
        guard let profile = profileService.profile else {
            print("Профиль не загружен")
            return
        }
        guard let view = view else {
            print("[updateProfile]: View is nil")
            return
        }
        view.updateProfile(profile: profile)
    }
    
    func updateAvatar() {
        guard let urlString = profileImageService.avatarURL,
              let url = URL(string: urlString) else {
            view?.updateAvatar(url: nil)
            return
        }
        guard let view = view else {
            print("[updateAvatar]: View is nil")
            return
        }
        view.updateAvatar(url: URL(string: profileImageService.avatarURL ?? ""))
    }
}
