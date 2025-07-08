import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var logoImage = UIImage()
    private var imageView = UIImageView()
    private var loginButton = UIButton()
    private var isFetchingToken = false
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupImageView()
        setupLoginButton()
        setupConstraints()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    // MARK: - ImageView Setup
    
    private func setupImageView() {
        guard let logoImage = UIImage(named: "auth_screen_logo") else {
            return
        }
        imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    // MARK: - LoginButton Setup
    
    private func setupLoginButton() {
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        loginButton.setTitleColor(UIColor(resource: .ypBlack), for: .normal)
        loginButton.backgroundColor = UIColor(resource: .ypWhite)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 16
        loginButton.contentMode = .scaleToFill
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        view.addSubview(loginButton)
    }
    
    // MARK: - Layout Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapLoginButton() {
        guard !isFetchingToken else { return }
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true, completion: nil)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    // MARK: - Cancellation
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Authentication
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.isFetchingToken = true
            self.fetchOAuthToken(code: code) { result in
                UIBlockingProgressHUD.dismiss()
                self.isFetchingToken = false
                switch result {
                case .success(let token):
                    self.delegate?.authViewController(self, didAuthenticateWithToken: token)
                case .failure(let error):
                    print("Ошибка получения токена: \(error)")
                    let alert = UIAlertController(
                        title: "Что-то пошло не так(",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - OAuth Token Fetching
    
    private func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                UIBlockingProgressHUD.dismiss()
                self.isFetchingToken = false
                switch result {
                case .success(let token):
                    completion(.success(token))
                case .failure(let error):
                    completion(.failure(error))
                    print("Ошибка получения токена: \(error)")
                }
            }
        }
    }
}
