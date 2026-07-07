//
//  WT2026App.swift
//  WT2026
//
//  Created by Jorge Silva on 07/07/2026.
//

import SwiftUI
import SwiftData

@main
struct WT2026App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: CodigoPostal.self
        )
    }
}
