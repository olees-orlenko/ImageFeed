import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private UI Properties
    
    private var logoImage = UIImage()
    private var imageView = UIImageView()
    
    // MARK: - Properties
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profile: Profile?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupImageView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("oauth2TokenStorage.token: \(oauth2TokenStorage.token ?? "nil")")
        if let token = oauth2TokenStorage.token {
            fetchProfile()
        } else {
            showAuthController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(named: "YP Black")
    }
    
    // MARK: - ImageView Setup
    
    private func setupImageView() {
        logoImage = UIImage(named: "Logo") ?? UIImage(systemName: "questionmark.circle")!
        imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    // MARK: - Layout Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 77.68),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)])
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
    
    private func showAuthController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: - Fetch Profile
    
    private func fetchProfile() {
        UIBlockingProgressHUD.show()
        guard let token = oauth2TokenStorage.token else {
            UIBlockingProgressHUD.dismiss()
            print("Токен не найден")
            return
        }
        profileService.fetchProfile(token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    UIBlockingProgressHUD.dismiss()
                    return }
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self.profile = profile
                    if let username = profile.username {
                        self.fetchProfileImageURL(username: username)
                    } else {
                        print("Имя пользователя отсутствует, невозможно загрузить URL изображения профиля")
                    }
                    self.switchToTabBarController()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("Не удалось загрузить профиль: \(error)")
                }
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let avatarURL):
                print("URL изображения профиля успешно загружен: \(avatarURL)")
            case .failure(let error):
                print("Ошибка при загрузке URL изображения профиля: \(error.localizedDescription)")}
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    // MARK: - Authentication with Token
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        UIBlockingProgressHUD.show()
        OAuth2TokenStorage.shared.token = token
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            self.fetchProfile()
        }
    }
}
