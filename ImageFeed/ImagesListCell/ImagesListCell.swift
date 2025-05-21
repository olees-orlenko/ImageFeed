import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static Properties

    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet

    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
}
