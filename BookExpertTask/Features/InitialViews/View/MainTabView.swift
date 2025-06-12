import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
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
