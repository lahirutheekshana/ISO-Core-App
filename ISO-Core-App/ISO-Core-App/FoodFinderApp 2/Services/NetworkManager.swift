import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case custom(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .noData: return "No data was returned from the server."
        case .decodingError: return "Failed to decode the response."
        case .custom(let error): return error.localizedDescription
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.noData
            }
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch _ as DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.custom(error)
        }
    }
}
