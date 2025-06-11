import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    @StateObject private var imageHandlerViewModel = ImageHandlerViewModel()
    @StateObject private var pdfViewModel = PDFViewModel()
    
    var body: some View {
        // Bottom Tab Bar
        TabView(selection: $selectedTab) {
            // Data Management
            DataManagementView()
                .tabItem {
                    VStack(spacing: 8) {
                        Image(systemName: "house")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                        Text("Home")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .tag(0)
            
            // PDF Viewer
            PDFView(viewModel: pdfViewModel)
                .tabItem {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        Text("PDF")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                }
                .tag(1)
            
            // Image Handler
            ImageHandlerView(viewModel: imageHandlerViewModel)
                .tabItem {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                        Text("Images")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .tag(2)
            
            // Profile
            ProfileView()
                .tabItem {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                        Text("User")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .tag(3)
        }
        .tabViewStyle(.automatic)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color(.systemBackground))
        .accentColor(.pink)
        .edgesIgnoringSafeArea(.bottom)
        .shadow(radius: 5)
    }
}

    


#Preview {
    DashboardView()
}
