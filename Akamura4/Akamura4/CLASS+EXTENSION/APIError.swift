enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unknown

    var title: String {
        switch self {
        case .invalidURL:
            return "無効なURL"
        case .invalidResponse:
            return "レスポンスエラー"
        case .invalidData:
            return "無効なデータ"
        case .unknown:
            return "不明なエラー"
        }
    }
}
