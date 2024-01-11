//
//  Adapty_DemoApp.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import SwiftUI
import UIKit

@main
struct Adapty_DemoApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var paywallService = PaywallService()
    @StateObject var userService = UserService()
    @State private var showingPaywall = false

    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.Palette.accent)]
    }

    // MARK: - UI

    var body: some Scene {
        WindowGroup {
            ContentView(showingPaywall: $showingPaywall)
                .environmentObject(paywallService)
                .environmentObject(userService)
                .onAppear {
                    if Adapty.delegate == nil {
                        Adapty.delegate = userService
                    }
                }
        }
    }

    // MARK: - Lifecycle

    private func processScenePhaseChange(to phase: ScenePhase) {
        switch phase {
        case .active, .background:
            break
        case .inactive:
            showingPaywall = false
        @unknown default:
            break
        }
    }
}
