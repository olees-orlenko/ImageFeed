import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError(message: "Некорректный ответ от сервера")))
                }
                return
            }
            guard (200...299).contains(response.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidStatusCode(message: "Сервер вернул ошибку: \(response.statusCode)")))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData(message: "Ошибка загрузки данных с сервера")))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        })
        return task
    }
}
