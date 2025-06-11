import SwiftUI

struct ProfileView: View {
    @ObservedObject private var authViewModel = AuthViewModel()
    @State private var showingMenu = false
    @State private var showingLogoutAlert = false
    @ObservedObject private var imageHandler = ImageHandlerViewModel()
   
    init() {
        // Load saved images if any exist
        imageHandler.loadSavedImages()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                HStack(spacing: 15) {
                    // Profile Image
                    if let photoURL = authViewModel.currentUser?.photoURL {
                        AsyncImage(url: photoURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray)
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    }
                    
                    // Profile Info and Stats
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.currentUser?.displayName ?? "Welcome Unknown user!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                     
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Profile Actions
                HStack() {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                
                if !imageHandler.savedImages.isEmpty {
                    Text("Saved Images")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(Array(imageHandler.savedImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width/3 - 15, height: UIScreen.main.bounds.width/3 - 15)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    Text("No saved images yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                }
            }
        }
        .sheet(isPresented: $showingMenu) {
            VStack(spacing: 20) {
                Text("Profile Actions")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    showingMenu = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(1))
                        .cornerRadius(10)
                }
            }
            .presentationDetents([.medium])
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
    }
}

#Preview {
    ProfileView()
}
