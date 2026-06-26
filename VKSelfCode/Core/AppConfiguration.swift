import Foundation

enum AppConfiguration {
    static let clientID = string(for: "VKIDClientID")
    static let clientSecret = string(for: "VKIDClientSecret")
    static let apiVersion = string(for: "VKAPIVersion", fallback: "5.199")
    static let authScope = string(
        for: "VKAuthScope",
        fallback: "vkid.personal_info wall photos groups friends"
    )

    static var isVKIDConfigured: Bool {
        !clientID.isEmpty &&
        clientID != "000000" &&
        !clientSecret.isEmpty &&
        clientSecret != "not-configured"
    }

    private static func string(for key: String, fallback: String = "") -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return fallback
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("$(") {
            return fallback
        }
        return trimmed.isEmpty ? fallback : trimmed
    }
}
