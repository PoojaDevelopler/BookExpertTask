import UIKit

enum AppTheme {
    case light
    case dark
    case system
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = "AppTheme"
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var currentTheme: AppTheme {
        get {
            guard let rawValue = defaults.string(forKey: themeKey),
                  let theme = AppTheme(rawValue: rawValue) else {
                return .system
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    private func applyTheme(_ theme: AppTheme) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = theme.userInterfaceStyle
            }
        }
    }
}

// MARK: - AppTheme RawRepresentable

extension AppTheme: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case "light":
            self = .light
        case "dark":
            self = .dark
        case "system":
            self = .system
        default:
            return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        case .system:
            return "system"
        }
    }
} 