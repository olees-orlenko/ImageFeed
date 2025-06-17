import UIKit

// MARK: - Delegate

protocol WebViewViewControllerDelegate: AnyObject {
    
    // MARK: - Authentication
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    // MARK: - Cancellation
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
