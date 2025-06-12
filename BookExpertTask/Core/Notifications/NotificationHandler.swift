//
//  NotificationHandler.swift
//  BookExpertTask
//
//  Created by pnkbksh on 12/06/25.
//

import Foundation
import Foundation
import Foundation
import UserNotifications



class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // This method tells iOS to show the notification even when the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification granted: \(granted)")
            }
        }
    }


    
    @MainActor
     func sendDeleteNotification(title:String , msgBody:String) {
        print("🟣 sendDeleteNotification() called")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = msgBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully")
            }
        }
    }
}
