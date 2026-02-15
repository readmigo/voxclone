import Foundation

struct Festival: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String

    static let presets: [Festival] = [
        Festival(id: "spring", name: "春节", emoji: "🧧"),
        Festival(id: "midautumn", name: "中秋", emoji: "🥮"),
        Festival(id: "lantern", name: "元宵", emoji: "🏮"),
        Festival(id: "dragon", name: "端午", emoji: "🐲"),
        Festival(id: "national", name: "国庆", emoji: "🇨🇳"),
        Festival(id: "birthday", name: "生日", emoji: "🎂"),
    ]
}
