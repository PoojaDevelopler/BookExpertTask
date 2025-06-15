import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
//                authenticatedView
                DashboardView()
            } else {
                loginView
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
    
    private var loginView: some View {
        VStack(spacing: Constants.UI.defaultSpacing * 2) {
            Image(systemName: "book.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Book Expert")
                .font(.title)
                .foregroundColor(.primary)
            
            Text("Sign in to access your account")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } label: {
                HStack {
                    Image("google_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("Sign in with Google")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.UI.defaultButtonHeight)
                .background(colorScheme == .dark ? Color.white : Color.black)
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(Constants.UI.defaultCornerRadius)
            }
            .padding(.horizontal, Constants.UI.defaultPadding)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
}

#Preview {
    AuthView()
} 
