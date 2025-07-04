import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Shared Instance
    
    static let shared = OAuth2TokenStorage()
    
    private init() {}

    // MARK: - Private Properties
    
    private let tokenKey = "OAuth2Token"

    // MARK: - Properties
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func removeToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
