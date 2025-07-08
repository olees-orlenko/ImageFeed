import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private UI Properties
    
    private var photoImage = UIImage()
    private var imageView = UIImageView()
    private var logoutButton = UIButton()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let textLabel = UILabel()
    
    // MARK: - Private Services
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.updateAvatar()
            }
        updateProfile()
        updateAvatar()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    // MARK: - ImageView Setup
    
    private func setupImageView() {
        photoImage = UIImage(named: "Photo") ?? UIImage(systemName: "person.crop.circle.fill")!
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
        logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout button") ?? UIImage(systemName: "arrow.backward")!,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.contentMode = .scaleToFill
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    // MARK: - NameLabel Setup
    
    private func setupNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.contentMode = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    // MARK: - NicknameLabel Setup
    
    private func setupNicknameLabel() {
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
    private func didTapLogoutButton(){
        OAuth2TokenStorage.shared.removeToken()
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
    
    // MARK: - Private Methods
    
    private func updateProfile() {
        guard let profile = profileService.profile else {
            print("Профиль не загружен")
            return
        }
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
        textLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard let urlString = profileImageService.avatarURL,
              let url = URL(string: urlString) else {
            imageView.image = UIImage(named: "Photo")
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Photo"),
            options: [.processor(processor)]
        )
    }
}
