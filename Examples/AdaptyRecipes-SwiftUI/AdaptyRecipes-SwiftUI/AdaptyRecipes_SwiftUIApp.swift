//
//  AdaptyRecipes_SwiftUIApp.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Adapty
import AdaptyUI
import SwiftUI

@main
struct AdaptyRecipes_SwiftUIApp: App {
    private let viewModel: MainViewModel

    init() {
        viewModel = MainViewModel()

        let adaptyConfigBuilder = AdaptyConfiguration
            .builder(withAPIKey: AppConstants.adaptyApiKey)
            .with(customerUserId: UserManager.currentUserId)

        Adapty.delegate = viewModel
        Adapty.logLevel = .verbose
        Adapty.activate(with: adaptyConfigBuilder)

#if canImport(UIKit)
        AdaptyUI.activate()
#endif
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
