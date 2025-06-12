//
//  UserModel.swift
//  BookExpertTask
//
//  Created by pnkbksh on 12/06/25.
//

import Foundation
import FirebaseAuth

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
