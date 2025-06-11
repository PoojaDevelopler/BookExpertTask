import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        do {
            return try await center.requestAuthorization(options: options)
        } catch {
            print("Error requesting notification authorization: \(error)")
            throw error
        }
    }
    
    func sendDeleteNotification(item: APIObjectEntity) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else { return }
        guard UserDefaults.standard.bool(forKey: "showDeleteNotifications") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Item Deleted"
        content.body = "\(item.name ?? "Item") has been deleted from your list."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
    
    func scheduleDeleteNotification(for item: APIObjectEntity) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else { return }
        guard UserDefaults.standard.bool(forKey: "showDeleteNotifications") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Item Deleted"
        content.body = "\(item.name ?? "Item") has been deleted from your list."
        content.sound = .default
        
        // Create a unique identifier for this notification
        let identifier = "delete-\(item.id ?? UUID().uuidString)"
        
        // Create the trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
