import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    
    @IBOutlet var gradientView: UIView!
    
    // MARK: - Private Properties
    
    private var gradientLayer: CAGradientLayer!
    var task: DownloadTask?
    
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
}
