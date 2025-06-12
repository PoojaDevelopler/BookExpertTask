import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

@main
struct BookExpertTaskApp: App {
    
    private let notificationDelegate = NotificationDelegate()
    private let notificationManager = NotificationManager.shared

    init() {
        FirebaseApp.configure()
        notificationManager.requestNotificationPermission()
        _ = notificationDelegate
    }

    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onOpenURL { url in
                    //  Handle Google Sign-In callback
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
} 

