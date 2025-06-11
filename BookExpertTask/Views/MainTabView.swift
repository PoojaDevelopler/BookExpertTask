import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    private let notificationViewModel = NotificationViewModel()
    private let notificationDelegate = NotificationDelegate()
    init(){
        notificationViewModel.requestNotificationPermission()
        _ = notificationDelegate
    }
    
    var body: some View {
        if authViewModel.isAuthenticated {
            DashboardView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    MainTabView()
} 
