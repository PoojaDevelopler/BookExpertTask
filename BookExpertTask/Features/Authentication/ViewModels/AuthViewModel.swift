import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CoreData

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        // Check if user is already logged in
        if let firebaseUser = Auth.auth().currentUser {
            self.currentUser = User(from: firebaseUser)
            self.isAuthenticated = true
            loadUserFromCoreData(userId: firebaseUser.uid)
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async {
       
       
        isLoading = true
        error = nil
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found"])
            isLoading = false
            return
        }
        
        print("Client ID: \(clientID)")
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
            isLoading = false
            return
        }
        
      
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"])
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.currentUser = User(from: authResult.user)
            self.isAuthenticated = true
            
            // Save user to Core Data
            saveUserToCoreData(user: authResult.user)
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.isUserLoggedIn)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Core Data Operations
    
    private func saveUserToCoreData(user: FirebaseAuth.User) {
        coreDataManager.saveUser(
            userId: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? ""
        )
    }
    
    private func loadUserFromCoreData(userId: String) {
        if let userEntity = coreDataManager.fetchUser(userId: userId) {
            // Update any necessary UI state with Core Data user info
            print("Loaded user from Core Data: \(userEntity.name ?? "")")
        }
    }
}

// MARK: - User Model

struct User {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL
    }
} 
