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

        let configuration = AdaptyConfiguration
            .builder(withAPIKey: AppConstants.adaptyApiKey)
            .with(customerUserId: UserManager.currentUserId)
            .build()

        Adapty.delegate = viewModel
        Adapty.logLevel = .verbose
        Adapty.activate(with: configuration)

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
