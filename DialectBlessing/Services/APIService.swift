import Foundation

actor APIService {
    static let shared = APIService()

    private let baseURL: String

    private init() {
        baseURL = "http://localhost:8000"
    }

    func generateGreeting(
        audioURL: URL,
        theme: String,
        customText: String,
        dialects: [Dialect]
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/api/v1/greeting/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Audio file
        let audioData = try Data(contentsOf: audioURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"recording.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)

        // Theme
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"theme\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(theme)\r\n".data(using: .utf8)!)

        // Custom text
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"custom_text\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(customText)\r\n".data(using: .utf8)!)

        // Dialects
        let dialectValues = dialects.map { $0.rawValue }.joined(separator: ",")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"dialects\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(dialectValues)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }

        struct GenerateResponse: Codable {
            let taskId: String
            enum CodingKeys: String, CodingKey {
                case taskId = "task_id"
            }
        }

        let result = try JSONDecoder().decode(GenerateResponse.self, from: data)
        return result.taskId
    }

    func checkStatus(taskId: String) async throws -> GreetingTask {
        let url = URL(string: "\(baseURL)/api/v1/greeting/status/\(taskId)")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }

        return try JSONDecoder().decode(GreetingTask.self, from: data)
    }

    func pollUntilComplete(taskId: String) async throws -> GreetingTask {
        for _ in 0..<60 {
            let task = try await checkStatus(taskId: taskId)

            switch task.status {
            case "completed":
                return task
            case "failed":
                throw APIError.taskFailed
            default:
                try await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        throw APIError.timeout
    }
}

enum APIError: LocalizedError {
    case serverError
    case taskFailed
    case timeout

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "服务器请求失败，请稍后重试"
        case .taskFailed:
            return "生成任务失败，请重试"
        case .timeout:
            return "请求超时，请稍后重试"
        }
    }
}
