import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private var profile: Profile?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("oauth2TokenStorage.token: \(oauth2TokenStorage.token ?? "nil")")
        if let token = oauth2TokenStorage.token {
            fetchProfile()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - Navigation (Prepare for Segue)

extension SplashViewController {
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare(for segue:) called with identifier: \(segue.identifier ?? "nil")")
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    // MARK: - Authentication
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = oauth2TokenStorage.token else {
            return
        }
        fetchProfile()
    }
    
    // MARK: - Fetch Profile
    
    private func fetchProfile() {
//            UIBlockingProgressHUD.show() // - не знаю нужно ли это, когда пользователь авторизован
            guard let token = oauth2TokenStorage.token else {
                UIBlockingProgressHUD.dismiss()
                print("Токен не найден")
                return
            }
            profileService.fetchProfile(token: token) { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    guard let self = self else { return }
                    switch result {
                    case .success(let profile):
                        self.profile = profile
                        self.switchToTabBarController()
                    case .failure(let error):
                        print("Не удалось загрузить профиль: \(error)")
                    }
                }
            }
        }

    // MARK: - Authentication with Token
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        OAuth2TokenStorage.shared.token = token
        switchToTabBarController()
        dismiss(animated: true)
    }
}
