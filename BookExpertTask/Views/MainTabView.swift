import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
//    private let notificationManager = NotificationManager.shared
//    private let notificationDelegate = NotificationDelegate()
//    init(){
//        notificationManager.requestNotificationPermission()
////        _ = notificationDelegate
//    }
//    
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
