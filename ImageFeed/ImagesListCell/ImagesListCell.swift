import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    
    @IBOutlet var gradientView: UIView!
    // MARK: - Private Properties
    
//    private var gradientView: UIView!
    private var gradientLayer: CAGradientLayer!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Setup Gradient
    
    private func setupGradient() {
        gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)
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
        dateLabel.backgroundColor = .clear
    }
    private func setupConstraints() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
