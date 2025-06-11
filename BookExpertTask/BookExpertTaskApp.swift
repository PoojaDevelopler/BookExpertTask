import SwiftUI
import FirebaseCore

@main
struct BookExpertTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init(){
        requestNotificationPermission()
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
} 
