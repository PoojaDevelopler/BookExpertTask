//
//  AppDelegate.swift
//  BookExpertTask
//
//  Created by pnkbksh on 10/06/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn
//+81 6543212345 101010
class AppDelegate: NSObject, UIApplicationDelegate {


    func application(_ application: UIApplication,
                        open url: URL,
                        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           return GIDSignIn.sharedInstance.handle(url)
       }

       func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
           FirebaseApp.configure()
           return true
       }

}

