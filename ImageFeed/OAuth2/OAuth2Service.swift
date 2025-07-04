import Foundation

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    // MARK: - Private Properties
    
    private var lastCode: String?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[fetchOAuthToken]: AuthServiceError - invalidRequest, code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        if task != nil {
            print("Отмена предыдущей задачи для code: \(lastCode ?? "nil")")
            task?.cancel()
        }
        lastCode = code
        print("Запуск новой задачи для code: \(code)")
        let request = authTokenRequest(code: code)
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                OAuth2TokenStorage.shared.token = response.accessToken
                print("Токен: \(response.accessToken)")
                completion(.success(response.accessToken))
            case .failure(let error):
                print("[fetchOAuthToken]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        task?.resume()
    }
    
    
    // MARK: - Private Methods
    
    private func authTokenRequest(code: String) -> URLRequest {
        guard let url = URL(string: WebViewConstants.unsplashAccessTokenURLString) else {
            print("Ошибка: Не удалось создать URL из WebViewConstants.unsplashAccessTokenURLString")
            guard let newURL = URL(string: "https://unsplash.com/oauth/token") else {
                fatalError("Failed to create new URL")
            }
            return URLRequest(url: newURL)
        }
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        let postString = parameters.map { key, value in
            return "\(key)=\(value)"
        }
            .joined(separator: "&")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: .utf8)
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("request httpBody: \(bodyString)")
        } else {
            print("request httpBody: nil or invalid encoding")
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "POST")")
        return request
    }
    
    private func resetLastCode() {
        lastCode = nil
    }
}
