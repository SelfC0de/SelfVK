import Foundation

enum VKAPIClientError: LocalizedError {
    case invalidURL
    case emptyResponse
    case api(VKAPIError)
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес VK API"
        case .emptyResponse:
            return "VK API вернул пустой ответ"
        case .api(let error):
            return error.message
        case .malformedResponse:
            return "Не удалось прочитать ответ VK API"
        }
    }
}

struct VKAPIError: Decodable, Error {
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case code = "error_code"
        case message = "error_msg"
    }
}

private struct VKEnvelope<Response: Decodable>: Decodable {
    let response: Response?
    let error: VKAPIError?
}

actor VKAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchCurrentUser(token: String) async throws -> VKUser {
        let users: [VKUser] = try await call(
            method: "users.get",
            token: token,
            parameters: [
                "fields": "photo_100,photo_200,photo_400_orig,domain,status,online,city,counters,verified"
            ]
        )
        guard let user = users.first else {
            throw VKAPIClientError.emptyResponse
        }
        return user
    }

    func fetchFeed(token: String, startFrom: String? = nil) async throws -> VKNewsfeedResponse {
        var parameters = [
            "count": "30",
            "filters": "post",
            "return_banned": "0"
        ]
        if let startFrom, !startFrom.isEmpty {
            parameters["start_from"] = startFrom
        }
        return try await call(method: "newsfeed.get", token: token, parameters: parameters)
    }

    private func call<Response: Decodable>(
        method: String,
        token: String,
        parameters: [String: String]
    ) async throws -> Response {
        guard let url = URL(string: "https://api.vk.com/method/\(method)") else {
            throw VKAPIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        var body = parameters
        body["access_token"] = token
        body["v"] = AppConfiguration.apiVersion
        request.httpBody = body
            .sorted { $0.key < $1.key }
            .map { "\($0.key.urlFormEncoded)=\($0.value.urlFormEncoded)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw VKAPIClientError.malformedResponse
        }

        let envelope = try decoder.decode(VKEnvelope<Response>.self, from: data)
        if let error = envelope.error {
            throw VKAPIClientError.api(error)
        }
        guard let value = envelope.response else {
            throw VKAPIClientError.emptyResponse
        }
        return value
    }
}

private extension String {
    var urlFormEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? self
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "-._~")
        return set
    }()
}
