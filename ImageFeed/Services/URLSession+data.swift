import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("[objectTask]: NetworkError - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("[objectTask]: NetworkError - codeError")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError(message: "Некорректный ответ от сервера")))
                }
                return
            }
            guard (200...299).contains(response.statusCode) else {
                print("[objectTask]: NetworkError - invalidStatusCode, code: \(response.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidStatusCode(message: "Сервер вернул ошибку: \(response.statusCode)")))
                }
                return
            }
            guard let data = data else {
                print("[objectTask]: NetworkError - noData")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData(message: "Ошибка загрузки данных с сервера")))
                }
                return
            }
            do {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError(message: "Невозможно декодировать данные")))
                }
            }
        }
        return task
    }
}
