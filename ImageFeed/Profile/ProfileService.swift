import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    
    static let shared = ProfileService()
    
    private init() {}
    
    // MARK: - Private Properties
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileRequest(token: token) else {
            print("[fetchProfile]: NetworkError - invalidURL")
            completion(.failure(NetworkError.invalidURL(message: "Неправильный URL")))
            return
        }
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[fetchProfile]: Error - \(error.localizedDescription)")
                completion(.failure(error))
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
        print("URLRequest URL: \(request.url?.absoluteString ?? "nil")")
        print("URLRequest HTTP Method: \(request.httpMethod ?? "GET")")
        return request
    }
}
