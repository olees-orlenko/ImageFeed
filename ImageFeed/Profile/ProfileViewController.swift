import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet var photoImage: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var nicknameLabel: UILabel!
    
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var logoutButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction private func didTapLogoutButton() {
    }
}
