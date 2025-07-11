import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let created_at: String?
    let updated_at: String?
    let width: Int
    let height: Int
    let color: String?
    let blur_hash: String?
    let likes: Int
    let liked_by_user: Bool
    let description: String?
    let user: UserResult
    let urls: UrlsResult
}

struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}
