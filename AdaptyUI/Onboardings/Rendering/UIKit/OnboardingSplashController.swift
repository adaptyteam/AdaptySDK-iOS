//
//  OnboardingSplashController.swift
//  Onboardings
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import UIKit

public final class OnboardingSplashController: UIViewController {
    private let id: String

    private weak var applicationSplashVC: UIViewController?
    private weak var onboardingVC: OnboardingController?

    private weak var delegate: OnboardingDelegate?
    private weak var splashDelegate: OnboardingSplashDelegate?

    @MainActor
    init(
        id: String,
        delegate: OnboardingDelegate,
        splashDelegate: OnboardingSplashDelegate
    ) {
        self.id = id
        self.delegate = delegate
        self.splashDelegate = splashDelegate

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

    private func layoutOnboarding() async throws -> OnboardingController {
        let onboardingVC = try await Onboardings.createOnboardingController(
            id: id,
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
        guard let splashDelegate,
              let childVC = splashDelegate.onboardingsSplashViewController()
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

extension OnboardingSplashController: OnboardingDelegate {
    public func onboardingController(_ controller: UIViewController, didFinishLoading action: OnboardingsDidFinishLoadingAction) {
        removeApplicationSplash()
    }
    
    public func onboardingController(_ controller: UIViewController, onCloseAction action: OnboardingsCloseAction) {
        delegate?.onboardingController(controller, onCloseAction: action)
    }

    public func onboardingController(_ controller: UIViewController, onPaywallAction action: OnboardingsOpenPaywallAction) {
        delegate?.onboardingController(controller, onPaywallAction: action)
    }

    public func onboardingController(_ controller: UIViewController, onCustomAction action: OnboardingsCustomAction) {
        delegate?.onboardingController(controller, onCustomAction: action)
    }

    public func onboardingController(_ controller: UIViewController, onStateUpdatedAction action: OnboardingsStateUpdatedAction) {
        delegate?.onboardingController(controller, onStateUpdatedAction: action)
    }

    public func onboardingController(_ controller: UIViewController, onAnalyticsEvent event: OnboardingsAnalyticsEvent) {
        delegate?.onboardingController(controller, onAnalyticsEvent: event)
    }

    public func onboardingController(_ controller: UIViewController, didFailWithError error: OnboardingsError) {
        delegate?.onboardingController(controller, didFailWithError: error)
    }
}
