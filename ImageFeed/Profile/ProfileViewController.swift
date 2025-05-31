import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var photoImage = UIImage()
    private var imageView = UIImageView()
    private var logoutButton = UIButton()
    private var nameLabel = UILabel()
    private var nicknameLabel = UILabel()
    private var textLabel = UILabel()
    
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
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.contentMode = .scaleToFill
        view.backgroundColor = UIColor(named: "YP Black")
    }
    
    // MARK: - ImageView Setup
    
    private func setupImageView() {
        photoImage = UIImage(named: "Photo") ?? UIImage(systemName: "person.crop.circle.fill")!
        imageView = UIImageView(image: photoImage)
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFit
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
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.contentMode = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    // MARK: - NicknameLabel Setup
    
    private func setupNicknameLabel() {
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = UIColor(named: "YP Gray")
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nicknameLabel.contentMode = .left
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameLabel)
    }
    
    // MARK: - TextLabel Setup
    
    private func setupTextLabel() {
        textLabel.text = "Hello, world!"
        textLabel.textColor = UIColor(named: "YP White")
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        textLabel.contentMode = .left
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton(){}
    
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
}

// MARK: - @IBOutlet

//    @IBOutlet var photoImage: UIImageView!
//    @IBOutlet var nameLabel: UILabel!
//    @IBOutlet var nicknameLabel: UILabel!
//    @IBOutlet var textLabel: UILabel!

//    @IBOutlet var logoutButton: UIButton!

// MARK: - Actions

//    @IBAction private func didTapLogoutButton() {
//    }

