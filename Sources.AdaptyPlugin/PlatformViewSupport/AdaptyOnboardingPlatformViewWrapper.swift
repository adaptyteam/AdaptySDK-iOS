//
//  AdaptyOnboardingPlatformViewWrapper.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/28/25.
//

import Adapty
import AdaptyUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public final class AdaptyOnboardingPlatformViewWrapper: UIView {
    private let eventHandler: EventHandler
    private let onboardingView: AdaptyOnboardingUIView

    package init(
        viewId: String,
        eventHandler: EventHandler,
        configuration: AdaptyUI.OnboardingConfiguration
    ) {
        self.eventHandler = eventHandler

        onboardingView = AdaptyOnboardingUIView(
            configuration: configuration,
            id: viewId
        )

        super.init(frame: .zero)
        
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
//        Log.ui.verbose("VC #\(logId)# layout begin")

        onboardingView.configure(delegate: self)
        onboardingView.layout(in: self)
        onboardingView.layoutWebViewAndPlaceholder()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyOnboardingPlatformViewWrapper: AdaptyOnboardingViewDelegate {
    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {}

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFailWithError error: AdaptyUIError
    ) {}

    package func onboardingsViewLoadingPlaceholder(
        _ view: AdaptyOnboardingUIView
    ) -> UIView? { nil }
}
