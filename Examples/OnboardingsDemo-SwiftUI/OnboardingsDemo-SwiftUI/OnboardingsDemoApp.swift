//
//  OnboardingsDemoApp.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import Adapty
import AdaptyUI
import SwiftUI

@main
struct OnboardingsDemoApp: App {
    let viewModel = ViewModel()

    init() {
        viewModel.activateAdapty()
    }

    var body: some Scene {
        WindowGroup {
            ApplicationMainView()
                .environmentObject(viewModel)
        }
    }
}
