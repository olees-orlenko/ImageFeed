import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    // MARK: - Properties
    
    var presenter: ProfileViewPresenterProtocol?
    
    // MARK: - Private UI Properties
    
    private var photoImage = UIImage()
    private var imageView = UIImageView()
    private var logoutButton = UIButton()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let textLabel = UILabel()
    
    // MARK: - Private Services
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupView()
        setupImageView()
        setupLogoutButton()
        setupNameLabel()
        setupNicknameLabel()
        setupTextLabel()
        setupConstraints()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.updateAvatar()
            }
    }
    
    // MARK: - Configuration
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    // MARK: - ImageView Setup
    
    private func setupImageView() {
        let defaultphotoImage = UIImage(systemName: "person.crop.circle.fill")
        let photoImage = UIImage(named: "Photo") ?? defaultphotoImage
        imageView = UIImageView(image: photoImage)
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    // MARK: - LogoutButton Setup
    
    private func setupLogoutButton() {
        logoutButton.accessibilityIdentifier = "logoutButton"
        let defaultImage = UIImage(systemName: "arrow.backward")
        let image = UIImage(named: "logout button") ?? defaultImage
        logoutButton = UIButton.systemButton(
            with: image ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.contentMode = .scaleAspectFit
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    // MARK: - NameLabel Setup
    
    private func setupNameLabel() {
        nameLabel.accessibilityLabel = "nameLabel"
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.contentMode = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    // MARK: - NicknameLabel Setup
    
    private func setupNicknameLabel() {
        nicknameLabel.accessibilityLabel = "nicknameLabel"
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = UIColor(resource: .ypGray)
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nicknameLabel.contentMode = .left
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameLabel)
    }
    
    // MARK: - TextLabel Setup
    
    private func setupTextLabel() {
        textLabel.text = "Hello, world!"
        textLabel.textColor = UIColor(resource: .ypWhite)
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        textLabel.contentMode = .left
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }
    
    // MARK: - Layout Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nicknameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    // MARK: - ProfileViewProtocol Methods
    
    func updateProfile(profile: Profile) {
        DispatchQueue.main.async {
            self.nameLabel.text = profile.name
            self.nicknameLabel.text = profile.loginName
            self.textLabel.text = profile.bio
        }
    }
    
    func updateAvatar(url: URL?) {
        DispatchQueue.main.async {
            guard let url = url else {
                self.imageView.image = UIImage(named: "Photo")
                return
            }
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Photo"),
                options: [.processor(processor)]
            )
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            ProfileLogoutService.shared.logout()
        }
        let cancel = UIAlertAction(title: "Нет", style: .default) { _ in
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
