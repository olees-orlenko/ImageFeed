import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Shared Instance
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"
    
    // MARK: - Properties
    
    var token: String? {
        get {
            userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
            userDefaults.synchronize()
        }
    }
}
