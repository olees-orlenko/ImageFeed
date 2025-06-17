import Foundation

// MARK: - Delegate

protocol AuthViewControllerDelegate: AnyObject {
    
    // MARK: - Authentication
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
