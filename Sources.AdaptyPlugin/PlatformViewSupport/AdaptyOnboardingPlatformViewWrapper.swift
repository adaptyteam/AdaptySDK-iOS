//
//  AdaptyOnboardingPlatformViewWrapper.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/28/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public final class AdaptyOnboardingPlatformViewWrapper: UIView {
    private let eventHandler: EventHandler
    private let onboardingView: AdaptyOnboardingUIView

    public init(
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
        onboardingView.configure(delegate: self)
        onboardingView.layout(in: self)
        onboardingView.layoutWebViewAndPlaceholder()
        onboardingView.callViewDidAppear()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyOnboardingPlatformViewWrapper: AdaptyOnboardingViewDelegate {
    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.DidFinishLoading(
                view: view.toAdaptyUIView(),
                action: action
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnCloseAction(
                view: view.toAdaptyUIView(),
                action: action
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnPaywallAction(
                view: view.toAdaptyUIView(),
                action: action
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnCustomAction(
                view: view.toAdaptyUIView(),
                action: action
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnStateUpdatedAction(
                view: view.toAdaptyUIView(),
                action: action
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnAnalyticsAction(
                view: view.toAdaptyUIView(),
                event: event
            )
        )
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFailWithError error: AdaptyUIError
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.DidFailWithError(
                view: view.toAdaptyUIView(),
                error: error
            )
        )
    }

    package func onboardingsViewLoadingPlaceholder(
        _ view: AdaptyOnboardingUIView
    ) -> UIView? {
        AdaptyPlugin.instantiateOnboardingPlaceholderView() ?? AdaptyOnboardingPlacehoderView()
    }
}

#endif
