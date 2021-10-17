import Foundation

struct Metric: Codable {
    let type: MetricsType
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case value = "_value"
    }
}

struct MetricsType: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "_name"
    }
}
