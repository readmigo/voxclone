import Foundation

struct DialectResult: Codable, Identifiable {
    var id: String { dialect }
    let dialect: String
    let dialectName: String
    let text: String
    let audioUrl: String

    enum CodingKeys: String, CodingKey {
        case dialect
        case dialectName = "dialect_name"
        case text
        case audioUrl = "audio_url"
    }
}

struct GreetingTask: Codable {
    let taskId: String
    let status: String
    let results: [DialectResult]?
    let combinedAudioUrl: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case results
        case combinedAudioUrl = "combined_audio_url"
        case createdAt = "created_at"
    }
}
