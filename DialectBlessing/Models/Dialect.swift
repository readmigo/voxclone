import Foundation

enum Dialect: String, CaseIterable, Identifiable, Codable {
    // 中文方言
    case mandarin = "mandarin"
    case cantonese = "cantonese"
    case sichuan = "sichuan"
    case dongbei = "dongbei"
    case shanghai = "shanghai"
    case minnan = "minnan"
    // 国际语言
    case english = "english"
    case japanese = "japanese"
    case korean = "korean"
    case spanish = "spanish"
    case french = "french"
    case russian = "russian"
    case german = "german"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mandarin: return "普通话"
        case .cantonese: return "粤语"
        case .sichuan: return "四川话"
        case .dongbei: return "东北话"
        case .shanghai: return "上海话"
        case .minnan: return "闽南语"
        case .english: return "English"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .spanish: return "Español"
        case .french: return "Français"
        case .russian: return "Русский"
        case .german: return "Deutsch"
        }
    }

    var description: String {
        switch self {
        case .mandarin: return "标准普通话，字正腔圆"
        case .cantonese: return "广东粤语，韵味十足"
        case .sichuan: return "巴蜀方言，麻辣鲜香"
        case .dongbei: return "东北腔调，热情豪爽"
        case .shanghai: return "吴侬软语，温婉细腻"
        case .minnan: return "闽南乡音，古韵悠长"
        case .english: return "Global language"
        case .japanese: return "丁寧で美しい日本語"
        case .korean: return "따뜻한 한국어 인사"
        case .spanish: return "Calidez latina"
        case .french: return "La langue de l'amour"
        case .russian: return "Душевный русский"
        case .german: return "Präzise und herzlich"
        }
    }

    var emoji: String {
        switch self {
        case .mandarin: return "🗣️"
        case .cantonese: return "🏮"
        case .sichuan: return "🌶️"
        case .dongbei: return "❄️"
        case .shanghai: return "🌃"
        case .minnan: return "🍵"
        case .english: return "🇬🇧"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .russian: return "🇷🇺"
        case .german: return "🇩🇪"
        }
    }

    /// 是否为中文方言
    var isChineseDialect: Bool {
        switch self {
        case .mandarin, .cantonese, .sichuan, .dongbei, .shanghai, .minnan:
            return true
        default:
            return false
        }
    }

    /// 中文方言列表
    static var chineseDialects: [Dialect] {
        allCases.filter { $0.isChineseDialect }
    }

    /// 国际语言列表
    static var internationalLanguages: [Dialect] {
        allCases.filter { !$0.isChineseDialect }
    }

    /// 默认选中：全部中文方言 + 英语和日语
    static var defaultSelection: Set<Dialect> {
        Set(chineseDialects + [.english, .japanese])
    }
}
