import Foundation

enum Constants {
    // MARK: - API
    
    enum API {
        static let baseURL = "https://api.restful-api.dev/objects"
        static let pdfURL = "https://www.africau.edu/images/default/sample.pdf"
    }
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        static let isUserLoggedIn = "isUserLoggedIn"
        static let userId = "userId"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    // MARK: - Notifications
    
    enum Notifications {
        static let deleteNotificationIdentifier = "deleteNotification"
        static let notificationCategory = "DELETE_CATEGORY"
    }
    
    // MARK: - Error Messages
    
    enum ErrorMessages {
        static let networkError = "Network error occurred. Please try again."
        static let authenticationError = "Authentication failed. Please try again."
        static let permissionDenied = "Permission denied. Please enable access in Settings."
        static let invalidData = "Invalid data received from server."
        static let unknownError = "An unknown error occurred. Please try again."
    }
    
    // MARK: - Validation
    
    enum Validation {
        static let minimumPasswordLength = 6
        static let maximumNameLength = 50
        static let maximumDescriptionLength = 500
    }
    
    // MARK: - UI
    
    enum UI {
        static let animationDuration: TimeInterval = 0.3
        static let defaultCornerRadius: CGFloat = 12
        static let defaultPadding: CGFloat = 16
        static let defaultSpacing: CGFloat = 12
        static let defaultButtonHeight: CGFloat = 44
        static let defaultIconSize: CGFloat = 24
    }
    
    // MARK: - File Management
    
    enum FileManagement {
        static let imageDirectory = "Images"
        static let maxImageSize: CGFloat = 1024
        static let imageQuality: CGFloat = 0.8
        static let supportedImageTypes = ["jpg", "jpeg", "png"]
    }
    
    // MARK: - Cache
    
    enum Cache {
        static let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
        static let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    }
    
}
