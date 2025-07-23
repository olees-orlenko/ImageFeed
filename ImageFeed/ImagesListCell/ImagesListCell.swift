import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: ImagesListCellDelegate?
    var photoId: String?
    var task: DownloadTask?

    // MARK: - Static Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var gradientView: UIView!
    
    // MARK: - Private Properties
    
    private var gradientLayer: CAGradientLayer!
    
    // MARK: - Actions
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - Setup Gradient
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        let startColor = UIColor.black.withAlphaComponent(0.0).cgColor
        let endColor = UIColor.black.withAlphaComponent(0.6).cgColor
        gradientLayer.colors = [startColor, endColor]
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.clipsToBounds = true
        contentView.clipsToBounds = false
    }
    
    // MARK: - Public Methods
    
    func setIsLiked(_ isLiked: Bool) {
            let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
            likeButton.setImage(likeImage, for: .normal)
        }
}
