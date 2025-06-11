//
//  NotificationViewModel.swift
//  BookExpertTask
//
//  Created by pnkbksh on 12/06/25.
//

import Foundation
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error)")
        } else {
            print("Notification granted: \(granted)")
        }
    }
}
