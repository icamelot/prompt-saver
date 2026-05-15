import SwiftUI
import Combine

enum Language: String, CaseIterable {
    case english = "en"
    case chinese = "zh"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }

    var shortName: String {
        switch self {
        case .english: return "EN"
        case .chinese: return "中文"
        }
    }
}

@MainActor
final class LocaleManager: ObservableObject {
    @AppStorage("appLanguage") var language: Language = .english
}
