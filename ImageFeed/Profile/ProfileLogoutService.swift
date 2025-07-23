import WebKit
import Foundation

final class ProfileLogoutService {
    
    // MARK: - Shared Instance
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        cleanCookies()
        cleanProfile()
        cleanImagesList()
        OAuth2TokenStorage.shared.removeToken()
        switchToSplashViewController()
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
    
    private func cleanProfile() {
        ProfileService.shared.clean()
        ProfileImageService.shared.clean()
    }
    
    private func cleanImagesList() {
        ImagesListService.shared.clean()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
