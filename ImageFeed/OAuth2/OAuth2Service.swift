import Foundation

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    // MARK: - Private Properties
    
    private var lastCode: String?
    private var task: URLSessionTask?
    private let decoder = JSONDecoder()
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code {
            return
        }
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("JSON ответ: \(String(data: data, encoding: .utf8) ?? "Невозможно декодировать данные")")
                    do {
                        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let authResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                        OAuth2TokenStorage.shared.token = authResponse.accessToken
                        print("Токен: \(authResponse.accessToken)")
                        completion(.success(authResponse.accessToken))
                    } catch {
                        let errorMessage = "Ошибка декодирования JSON: \(error.localizedDescription)"
                        print("Ошибка: \(errorMessage)")
                        completion(.failure(NetworkError.decodingError(message: errorMessage)))
                    }
                case .failure(let error):
                    print("Ошибка: \(error)")
                    completion(.failure(error))
                }
            }
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
