//
//  PriconneDBApp.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2025/11/25.
//

import AppFeature
import FirebaseCore
import Resources
import SwiftUI

@main
struct PriconneDBApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(.appAccent)
        }
    }

    init() {
        FirebaseApp.configure()
    }
}
