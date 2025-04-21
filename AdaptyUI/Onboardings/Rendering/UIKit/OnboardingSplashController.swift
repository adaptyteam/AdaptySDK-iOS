//
//  OnboardingSplashController.swift
//  Onboardings
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import UIKit
import Adapty

public final class OnboardingSplashController: UIViewController {
    private let configuration: AdaptyUI.OnboardingConfiguration

    private weak var applicationSplashVC: UIViewController?
    private weak var onboardingVC: AdaptyOnboardingController?

    private weak var delegate: AdaptyOnboardingControllerDelegate?
    private weak var placeholderDelegate: AdaptyOnboardingPlaceholderDelegate?

    @MainActor
    init(
        configuration: AdaptyUI.OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate,
        placeholderDelegate: AdaptyOnboardingPlaceholderDelegate
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.placeholderDelegate = placeholderDelegate

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        applicationSplashVC = layoutApplicationSplash()

        Task {
            onboardingVC = try? await layoutOnboarding()
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applicationSplashVC?.beginAppearanceTransition(true, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        applicationSplashVC?.endAppearanceTransition()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        applicationSplashVC?.beginAppearanceTransition(false, animated: animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        applicationSplashVC?.endAppearanceTransition()
    }

    private func layoutOnboarding() async throws -> AdaptyOnboardingController {
        let onboardingVC = try await AdaptyUI.createOnboardingController(
            configuration: configuration,
            delegate: self
        )

        layoutChildController(onboardingVC, at: 0)
        return onboardingVC
    }

    private func layoutChildController(_ childVC: UIViewController, at index: Int? = nil) {
        if let index {
            view.insertSubview(childVC.view, at: index)
        } else {
            view.addSubview(childVC.view)
        }

        addChild(childVC)
        childVC.didMove(toParent: self)

        view.addConstraints([
            childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        childVC.view.clipsToBounds = true
    }

    private func layoutApplicationSplash() -> UIViewController? {
        guard let childVC = placeholderDelegate?.onboardingsControllerPlaceholderController()
        else {
            return nil
        }

        layoutChildController(childVC)

        return childVC
    }

    private func removeApplicationSplash() {
        guard let applicationSplashVC else { return }

        UIView.animate(
            withDuration: 0.3,
            delay: 0.5,
            animations: {
                applicationSplashVC.view.alpha = 0.0

            }, completion: { _ in
                applicationSplashVC.willMove(toParent: nil)
                applicationSplashVC.view.removeFromSuperview()
                applicationSplashVC.removeFromParent()

                self.applicationSplashVC = nil
            }
        )
    }
}

extension OnboardingSplashController: AdaptyOnboardingControllerDelegate {
    public func onboardingController(_ controller: AdaptyOnboardingController, didFinishLoading action: OnboardingsDidFinishLoadingAction) {
        removeApplicationSplash()
    }
    
    public func onboardingController(_ controller: AdaptyOnboardingController, onCloseAction action: OnboardingsCloseAction) {
        delegate?.onboardingController(controller, onCloseAction: action)
    }

    public func onboardingController(_ controller: AdaptyOnboardingController, onPaywallAction action: OnboardingsOpenPaywallAction) {
        delegate?.onboardingController(controller, onPaywallAction: action)
    }

    public func onboardingController(_ controller: AdaptyOnboardingController, onCustomAction action: OnboardingsCustomAction) {
        delegate?.onboardingController(controller, onCustomAction: action)
    }

    public func onboardingController(_ controller: AdaptyOnboardingController, onStateUpdatedAction action: OnboardingsStateUpdatedAction) {
        delegate?.onboardingController(controller, onStateUpdatedAction: action)
    }

    public func onboardingController(_ controller: AdaptyOnboardingController, onAnalyticsEvent event: OnboardingsAnalyticsEvent) {
        delegate?.onboardingController(controller, onAnalyticsEvent: event)
    }

    public func onboardingController(_ controller: AdaptyOnboardingController, didFailWithError error: AdaptyUIError) {
        delegate?.onboardingController(controller, didFailWithError: error)
    }
}
