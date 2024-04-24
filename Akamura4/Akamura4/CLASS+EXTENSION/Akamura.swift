import Foundation

// イベント・年間行事
struct Events: Codable {
    var header: String
    var isShown: Bool
    var contents: [Contents]
}

struct Contents: Codable {
    var month: String
    var title: String
    var image: String
    var showType: String
    var url: String
    var picture: String
    var detail: String
    var video: String
}

// 天気API
struct OpenWeather: Codable {
    let weather: [Weather]
    let main: Main

    struct Weather: Codable {
        let icon: String
    }

    struct Main: Codable {
        var temperature: Double
        var minTemperature: Double
        var maxTemperature: Double

        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
        }
    }
}

// 施設紹介
struct FacilityContent: Codable {
    struct Contents: Codable {
        var title: String
        var subTitle: String
        var picture: String
        var site: String
        var contact: String
    }

    var header: String
    var isShown: Bool
    var address: String
    var phoneNumber: String
    var mainSite: String
    var facebook: String
    var contents: [Contents]
}

// Map関連
struct PinData: Codable {
    var title: String //ピンの場所の名前
    var latitude: Double //緯度
    var longitude: Double //経度
    var category: String//ピン色
    var photo: String //写真
    var explanation: String //説明
}

// レビュー
struct Review: Codable {
    let id: String
    let userId: String?
    let title: String
    let comment: String
    let age: String
    let satisfied: String
    let modified: String
    let posted: String
    let flag: String
}
