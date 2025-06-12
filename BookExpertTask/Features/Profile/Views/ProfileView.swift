import SwiftUI

struct ProfileView: View {
    @ObservedObject private var authViewModel = AuthViewModel()
    @ObservedObject private var imageHandler = ImageHandlerViewModel()
    
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // MARK: - Profile Card
                VStack(spacing: 12) {
                    // Profile Image
                    if let photoURL = authViewModel.currentUser?.photoURL {
                        AsyncImage(url: photoURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 4)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 90, height: 90)
                    }
                    
                    // Name and email
                    Text(authViewModel.currentUser?.displayName ?? "Welcome, Guest")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // MARK: - Logout Button
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                // MARK: - Saved Images Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Saved Images")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    if imageHandler.savedImages.isEmpty {
                        Text("No saved images yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(Array(imageHandler.savedImages.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 3 - 15,
                                           height: UIScreen.main.bounds.width / 3 - 15)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
        }
        .alert("Logout Confirmation", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
