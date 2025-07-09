import UIKit

enum Constants {
    
    // MARK: - Static Properties
    
    static let accessKey = "CzbkiPeYfnZqSSLaqNHnPfZsYMavhNoEsryPJncAPkQ"
    static let secretKey = "igS5XIJcZjHf1kvdzNvOd3_v6IxgM1mmq49VbdkTJqk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}

enum WebViewConstants {
    
    // MARK: - Static Properties
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashAccessTokenURLString = "https://unsplash.com/oauth/token"
    static let unsplashProfileURLString = "https://api.unsplash.com/me"
    static let unsplashProfileImageURLString = "https://api.unsplash.com/users"
}

enum HttpConstants: String {
    case get = "GET"
    case post = "POST"
}
