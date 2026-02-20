//
//  Adapty_Recipes_SwiftUI_NativeMacOSApp.swift
//  Adapty-Recipes-SwiftUI-NativeMacOS
//
//  Created by Никита Куприянов on 20.02.2026.
//

import Adapty
import AdaptyUI
import SwiftUI
internal import AdaptyLogger

@main
struct Adapty_Recipes_SwiftUI_NativeMacOSApp: App {
    private let viewModel: MainViewModel

    init() {
        viewModel = MainViewModel()

        let configuration = AdaptyConfiguration
            .builder(withAPIKey: AppConstants.adaptyApiKey)
            .with(customerUserId: UserManager.currentUserId)
            .build()

        Adapty.delegate = viewModel
        Adapty.logLevel = .info
        Adapty.activate(with: configuration)

        AdaptyUI.activate()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.reloadProfile()
                }
        }
    }
}
