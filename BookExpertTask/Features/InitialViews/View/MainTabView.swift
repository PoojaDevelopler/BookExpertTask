import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        //        if authViewModel.isAuthenticated {
        //            DashboardView()
        //        } else {
        //            AuthView()
        //        }
        
        return Group {
            if authViewModel.isAuthenticated {
                DashboardView()
            } else {
                AuthView()
            }
        }
    }
    
    
}

#Preview {
    MainTabView()
} 
