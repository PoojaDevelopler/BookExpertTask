import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    private let notificationDelegate = NotificationDelegate()
    init(){
        requestNotificationPermission()
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
