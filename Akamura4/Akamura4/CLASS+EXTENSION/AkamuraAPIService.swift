import Foundation

final class AkamuraAPIService {
    static let shared = AkamuraAPIService()

    // responseTypeにデコードしたいstructを代入 request(with: weatherApiUrl, responseType: OpenWeather.self)
    func request<T: Codable>(with urlString: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpStatus = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            switch httpStatus.statusCode {
                case 200:
                    let contents = try JSONDecoder().decode(T.self, from: data)
                    return contents
                default:
                    throw APIError.invalidData
            }
        } catch {
            throw APIError.invalidData
        }
    }

    func request<T: Codable>(with urlString: String, responseArrayType: T.Type) async throws -> [T] {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpStatus = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            switch httpStatus.statusCode {
                case 200:
                    let contents = try JSONDecoder().decode([T].self, from: data)
                    return contents
                default:
                    throw APIError.invalidData
            }
        } catch {
            throw APIError.invalidData
        }
    }

    func fetchImage(with urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpStatus = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            switch httpStatus.statusCode {
                case 200:
                    return data
                default:
                    throw APIError.invalidData
            }
        } catch {
            throw APIError.invalidData
        }
    }
}
