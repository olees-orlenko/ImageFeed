import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    
    static let shared = ProfileService()
    
    private init() {}
    
    // MARK: - Private Properties
    
    private var task: URLSessionTask?
    private let decoder = JSONDecoder()
    private(set) var profile: Profile?
    
    // MARK: - Public Methods

    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidURL(message: "Неправильный URL")))
            return
        }
        task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                switch result {
                case .success(let data):
                    print("JSON ответ: \(String(data: data, encoding: .utf8) ?? "Невозможно декодировать данные")")
                    do {
                        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let profileResult = try self.decoder.decode(ProfileResult.self, from: data)
                        let profile = Profile(
                            username: profileResult.username,
                            name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                            loginName: "@\(profileResult.username)",
                            bio: profileResult.bio ?? "",
                            profileImageSmall: profileResult.profileImage?.small,
                            profileImageMedium: profileResult.profileImage?.medium,
                            profileImageLarge: profileResult.profileImage?.large
                        )
                        self.profile = profile
                        completion(.success(profile))
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
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: WebViewConstants.unsplashProfileURLString) else {
            print("Ошибка: Не удалось создать URL из WebViewConstants.unsplashProfileURLString")
            guard let newURL = URL(string: "https://api.unsplash.com/me") else {
                fatalError("Failed to create new URL")
            }
            return URLRequest(url: newURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("request httpBody: \(bodyString)")
        } else {
            print("request httpBody: nil or invalid encoding")
        }
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
