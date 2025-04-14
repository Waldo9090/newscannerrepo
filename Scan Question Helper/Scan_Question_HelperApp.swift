//
//  Scan_Question_HelperApp.swift
//  Scan Question Helper
//
//  Created by Aditya Mahna on 4/12/25.
//

import SwiftUI
import SuperwallKit
import FirebaseCore

// Add AppDelegate for Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configured!") // Optional: Log confirmation
    return true
  }
}

@main
struct Scan_Question_HelperApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Access AppStorage value to decide initial view
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false

    init() {
        Superwall.configure(apiKey: "pk_5dd4f309b5cb7eef5181d4392188197f9b470e6b89d78dea")
    }
    
    var body: some Scene {
        WindowGroup {
            // Conditionally show Onboarding or TabBarView
            if isOnboardingComplete {
                TabBarView()
            } else {
                UnifiedOnboardingView()
            }
        }
    }
}
