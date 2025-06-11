import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Settings")) {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    
                    if viewModel.notificationsEnabled {
                        Toggle("Show Delete Notifications", isOn: $viewModel.showDeleteNotifications)
                    }
                }
                
                Section(header: Text("Status")) {
                    Text(viewModel.authorizationStatus)
                }
            }
            .navigationTitle("Notifications")
            .onAppear {
                viewModel.requestAuthorization()
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}
