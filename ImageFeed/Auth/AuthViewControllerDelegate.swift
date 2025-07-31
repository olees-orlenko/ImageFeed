import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    
    // MARK: - Authentication
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}
