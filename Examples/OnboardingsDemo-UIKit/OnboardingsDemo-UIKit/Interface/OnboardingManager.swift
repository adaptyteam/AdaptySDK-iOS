//
//  OnboardingManager.swift
//  OctoflowsDemo-UIKit
//
//  Created by Aleksey Goncharov on 02.08.2024.
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

final class OnboardingManager: NSObject {
    static let shared = OnboardingManager()

    @MainActor
    fileprivate var window: UIWindow?

    @MainActor
    func initialize(scene: UIScene) -> UIWindow? {
        activateAdapty()

        guard let windowScene = (scene as? UIWindowScene) else { return nil }

        window = UIWindow(windowScene: windowScene)
        resolveApplicationState()
        return window
    }

    @MainActor
    func resolveApplicationState() {
        guard let window else { return }

        if UserDefaults.standard.didFinishOnboarding {
            window.rootViewController = ViewController.instantiate()
            window.makeKeyAndVisible()
        } else {
            window.rootViewController = SplashController()
            window.makeKeyAndVisible()

            Task { @MainActor in
                await loadAndPresentOnboarding()
            }
        }
    }

    @MainActor
    private func activateAdapty() {
        Task {
            do {
                let configBuilder = AdaptyConfiguration
                    .builder(withAPIKey: "YOUR_API_KEY")

                try await Adapty.activate(with: configBuilder.build())
                try await AdaptyUI.activate()
            } catch {
                // handle the error
            }
        }
    }

    @MainActor
    private func loadAndPresentOnboarding() async {
        guard let window else { return }

        do {
            let onboarding = try await Adapty.getOnboarding(placementId: "YOUR_ONBOARDING_ID")
            let onboardingConfiguration = AdaptyUI.getOnboardingConfiguration(forOnboarding: onboarding)
            let onboardingController = AdaptyUI.createOnboardingController(configuration: onboardingConfiguration, delegate: self)

            window.rootViewController = onboardingController
        } catch {
            // handle error
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingManager: AdaptyOnboardingControllerDelegate {
    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {}

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        guard let window else { return }

        window.rootViewController = ViewController.instantiate()

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {}
        )

        UserDefaults.standard.didFinishOnboarding = true
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {}

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {}

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {}

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {}

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFailWithError error: AdaptyUIError
    ) {}

    func onboardingsControllerLoadingPlaceholder(
        _ controller: AdaptyOnboardingController
    ) -> UIView? {
        SplashView(frame: .zero)
    }
}
