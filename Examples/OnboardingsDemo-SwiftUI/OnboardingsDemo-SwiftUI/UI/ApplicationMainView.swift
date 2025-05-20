//
//  ApplicationMainView.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 12.08.2024.
//

import Adapty
import AdaptyUI
import SwiftUI

struct ApplicationMainView: View {
    @EnvironmentObject var viewModel: ViewModel

    @State var errorAlert: IdentifiableErrorWrapper?

    @ViewBuilder
    private var onboardingOrSplash: some View {
        if let onboardingConfiguration = viewModel.onboardingConfiguration {
            AdaptyOnboardingView(
                configuration: onboardingConfiguration,
                placeholder: { ApplicationSplashView() },
                onCloseAction: { _ in
                    withAnimation {
                        viewModel.onboardingFinished = true
                    }
                },
                onOpenPaywallAction: { action in
                    loadAndPresentPaywall(action.actionId)
                },
                onError: { error in
                    errorAlert = .init(value: error)
                }
            )
        } else {
            ApplicationSplashView()
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                ApplicationContentView()
            }
            .zIndex(0)

            if !viewModel.onboardingFinished {
                onboardingOrSplash
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            viewModel.onError = { error in
                errorAlert = .init(value: error)
            }

            viewModel.loadOnboardingConfiguration()
        }
        .alert(item: $errorAlert) { error in
            Alert(
                title: Text("Error!"),
                message: Text(error.value.localizedDescription),
                dismissButton: .cancel()
            )
        }
        .paywall(
            isPresented: $paywallPresented,
            fullScreen: true,
            paywallConfiguration: paywallConfig,
            didFailPurchase: { _, _ in },
            didFinishRestore: { _ in },
            didFailRestore: { _ in },
            didFailRendering: { _ in }
        )
    }

    @State private var paywallPresented = false
    @State private var paywallConfig: AdaptyUI.PaywallConfiguration?

    private func loadAndPresentPaywall(_ placementId: String) {
        Task {
            let paywall = try await Adapty.getPaywall(placementId: placementId)
            let config = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)

            self.paywallConfig = config
            self.paywallPresented = true
        }
    }
}
