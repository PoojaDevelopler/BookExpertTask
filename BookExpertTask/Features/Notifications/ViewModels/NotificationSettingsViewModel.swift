import Foundation
import UserNotifications

class NotificationSettingsViewModel: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var showDeleteNotifications = true
    @Published var authorizationStatus = "Not Determined"
    @Published var error: Error?
    
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadSettings()
        updateAuthorizationStatus()
    }
    
    func requestAuthorization() {
        Task {
            do {
                notificationsEnabled = try await notificationManager.requestAuthorization()
                updateAuthorizationStatus()
            } catch {
                self.error = error
            }
        }
    }
    
    func sendDeleteNotification(item: APIObjectEntity) {
        guard notificationsEnabled && showDeleteNotifications else { return }
        notificationManager.scheduleDeleteNotification(for: item)
    }
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        showDeleteNotifications = UserDefaults.standard.bool(forKey: "showDeleteNotifications")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(showDeleteNotifications, forKey: "showDeleteNotifications")
    }
    
    private func updateAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.authorizationStatus = "Authorized"
                case .denied:
                    self.authorizationStatus = "Denied"
                case .notDetermined:
                    self.authorizationStatus = "Not Determined"
                case .provisional:
                    self.authorizationStatus = "Provisional"
                case .ephemeral:
                    self.authorizationStatus = "Ephemeral"
                @unknown default:
                    self.authorizationStatus = "Unknown"
                }
            }
        }
    }
}
