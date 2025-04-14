//
//  Scan_Question_HelperApp.swift
//  Scan Question Helper
//
//  Created by Aditya Mahna on 4/12/25.
//

import SwiftUI
import SuperwallKit

@main
struct Scan_Question_HelperApp: App {
    init() {
        Superwall.configure(apiKey: "pk_5dd4f309b5cb7eef5181d4392188197f9b470e6b89d78dea")
    }
    
    var body: some Scene {
        WindowGroup {
            UnifiedOnboardingView()
        }
    }
}
