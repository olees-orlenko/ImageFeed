import SwiftKeychainWrapper
import WebKit
import Foundation

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
        print("Logout")
    }
}

final class ProfileLogoutService {
    
    // MARK: - Shared Instance
    
   static let shared = ProfileLogoutService()
  
   private init() { }

    // MARK: - Public Methods
    
   func logout() {
      cleanCookies()
   }

    // MARK: - Private Methods

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
