import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

@main
struct BookExpertTaskApp: App {
    
    private let notificationDelegate = NotificationDelegate()
    private let notificationManager = NotificationManager.shared
    @State private var showSplash = true
    @StateObject private var authViewModel = AuthViewModel() // ✅ Shared instance
    
    init() {
        FirebaseApp.configure()
        notificationManager.requestNotificationPermission()
        _ = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainTabView()
                    .environmentObject(authViewModel) // ✅ Inject here
                    .onOpenURL { url in
                        //  Handle Google Sign-In callback
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
}

