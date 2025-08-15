//
//  ViewModel.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 12.08.2024.
//

import Adapty
import AdaptyUI
import UIKit

extension UserDefaults {
    var didFinishOnboarding: Bool {
        get {
            bool(forKey: "didFinishOnboarding")
        } set {
            set(newValue, forKey: "didFinishOnboarding")
        }
    }
}

final class ViewModel: ObservableObject {
    var onError: ((Error) -> Void)?

    @Published var onboardingFinished: Bool {
        didSet {
            UserDefaults.standard.didFinishOnboarding = onboardingFinished
        }
    }

    @Published var onboardingConfiguration: AdaptyUI.OnboardingConfiguration?

    init() {
        self.onboardingFinished = UserDefaults.standard.didFinishOnboarding
    }

    @MainActor
    func activateAdapty() {
        Task {
            do {
                Adapty.logLevel = .info

                #error("Change this constant with your own API key, then remove this line.")
                let apiKey = "YOUR_API_KEY"

                let configBuilder = AdaptyConfiguration
                    .builder(withAPIKey: apiKey)

                try await Adapty.activate(with: configBuilder.build())
                try await AdaptyUI.activate()
            } catch {
                // handle the error
            }
        }
    }

    func loadOnboardingConfiguration() {
        Task { @MainActor in
            do {
                let onboarding = try await Adapty.getOnboarding(placementId: "YOUR_PLACEMENT_ID")
                self.onboardingConfiguration = try AdaptyUI.getOnboardingConfiguration(forOnboarding: onboarding)
            } catch {
                onError?(error)
            }
        }
    }
}
