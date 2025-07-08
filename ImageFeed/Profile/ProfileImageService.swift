import Foundation

final class ProfileImageService{
    
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private init() {}
    
    // MARK: - Private Properties
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    // MARK: - Public Methods
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileImageRequest(username: username) else {
            print("[fetchProfileImageURL]: NetworkError - invalidURL")
            completion(.failure(NetworkError.invalidURL(message: "Неправильный URL")))
            return
        }
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let userResult):
                guard let avatarURL = userResult.profileImage.large ?? userResult.profileImage.medium ?? userResult.profileImage.small else { return }
                self.avatarURL = avatarURL
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                completion(.success(avatarURL))
            case .failure(let error):
                print("[fetchProfileImageURL]: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "\(WebViewConstants.unsplashProfileImageURLString)/\(username)") else {
            print("Ошибка: Не удалось создать URL из WebViewConstants.unsplashProfileImageURLString")
            guard let newURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
                fatalError("Failed to create new URL")
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токен не найден")
            return nil
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
