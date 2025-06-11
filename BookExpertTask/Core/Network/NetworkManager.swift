import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Error decoding data"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.restful-api.dev/objects"
    
    private init() {}
    
    // MARK: - API Methods
    
    func fetchObjects() async throws -> [[String: Any]] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200:
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw NetworkError.decodingError
            }
            return jsonArray
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func createObject(_ object: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: object)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...201:
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NetworkError.decodingError
            }
            return jsonObject
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func updateObject(id: String, object: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: object)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200:
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NetworkError.decodingError
            }
            return jsonObject
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func deleteObject(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...204:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
} 