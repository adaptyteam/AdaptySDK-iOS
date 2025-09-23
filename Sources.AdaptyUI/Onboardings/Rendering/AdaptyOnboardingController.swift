//
//  AdaptyOnboardingController.swift
//
//
//  Created by Aleksey Goncharov on 02.08.2024.
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public final class AdaptyOnboardingController: UIViewController {
    public var id: String { onboardingView.id }
    public var onboarding: AdaptyOnboarding { onboardingView.configuration.viewModel.onboarding }

    private let onboardingView: AdaptyOnboardingUIView
    weak var delegate: AdaptyOnboardingControllerDelegate?

    private let statusBarStyle: UIStatusBarStyle
    private let logId: String

    override public var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

    init(
        configuration: AdaptyUI.OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate,
        statusBarStyle: UIStatusBarStyle
    ) {
        self.delegate = delegate
        self.statusBarStyle = statusBarStyle
        logId = configuration.viewModel.logId

        onboardingView = AdaptyOnboardingUIView(configuration: configuration)

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.ui.verbose("#\(logId)# deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        Log.ui.verbose("VC #\(logId)# viewDidLoad begin")

        onboardingView.configure(delegate: self)
        onboardingView.layout(in: view)
        onboardingView.layoutWebViewAndPlaceholder()

        Log.ui.verbose("VC #\(logId)# viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Log.ui.verbose("VC #\(logId)# viewDidAppear")

        onboardingView.configuration.viewModel.viewDidAppear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        Log.ui.verbose("VC #\(logId)# viewDidDisappear")
        onboardingView.configuration.viewModel.viewDidDisappear()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyOnboardingController: AdaptyOnboardingViewDelegate {
    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        delegate?.onboardingController(self, didFinishLoading: action)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        delegate?.onboardingController(self, onCloseAction: action)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        delegate?.onboardingController(self, onPaywallAction: action)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        delegate?.onboardingController(self, onCustomAction: action)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        delegate?.onboardingController(self, onStateUpdatedAction: action)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        delegate?.onboardingController(self, onAnalyticsEvent: event)
    }

    package func onboardingView(
        _ view: AdaptyOnboardingUIView,
        didFailWithError error: AdaptyUIError
    ) {
        delegate?.onboardingController(self, didFailWithError: error)
    }

    package func onboardingsViewLoadingPlaceholder(
        _ view: AdaptyOnboardingUIView
    ) -> UIView? {
        delegate?.onboardingsControllerLoadingPlaceholder(self)
    }
}

#endif
