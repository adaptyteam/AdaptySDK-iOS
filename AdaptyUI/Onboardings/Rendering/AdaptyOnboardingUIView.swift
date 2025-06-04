//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/19/25.
//

#if canImport(UIKit)

import Adapty
import UIKit
import WebKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension WKWebView {
    static func createForOnboarding() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)

        return webView
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package final class AdaptyOnboardingUIView: UIView {
    let id: String
    let configuration: AdaptyUI.OnboardingConfiguration
    var onboarding: AdaptyOnboarding { configuration.viewModel.onboarding }

    private var viewModel: AdaptyOnboardingViewModel { configuration.viewModel }
    private let logId: String

    private var webView = WKWebView.createForOnboarding()

    weak var delegate: AdaptyOnboardingViewDelegate?

    package init(
        configuration: AdaptyUI.OnboardingConfiguration,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.configuration = configuration
        self.logId = configuration.viewModel.logId

        super.init(frame: .zero)

        viewModel.onMessage = { [weak self] message in
            self?.handleMessage(message)
        }

        viewModel.onError = { [weak self] error in
            self?.handleError(error)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.ui.verbose("V #\(logId)# deinit")
    }

    private func handleMessage(_ message: AdaptyOnboardingsMessage) {
        if case .didFinishLoading = message {
            placeholderView?.removeFromSuperview()
            placeholderView = nil
        }

        delegate?.apply(message: message, from: self)
    }

    private func handleError(_ error: AdaptyUIError) {
        delegate?.apply(error: error, from: self)
    }

    package func configure(delegate: AdaptyOnboardingViewDelegate) {
        Log.ui.verbose("V #\(logId)# configure")

        self.delegate = delegate
        viewModel.configureWebView(webView)
    }

    private var placeholderView: UIView?

    package func layout(in parentView: UIView) {
        Log.ui.verbose("V #\(logId)# layout(in:)")

        translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(self)

        parentView.addConstraints([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            topAnchor.constraint(equalTo: parentView.topAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])
    }

    package func layoutWebViewAndPlaceholder() {
        Log.ui.verbose("V #\(logId)# layoutWebView")

        webView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(webView)

        addConstraints([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let placeholderView = delegate?.onboardingsViewLoadingPlaceholder(self) {
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(placeholderView)

            addConstraints([
                placeholderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                placeholderView.topAnchor.constraint(equalTo: topAnchor),
                placeholderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                placeholderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            self.placeholderView = placeholderView
        }
    }
    
    package func callViewDidAppear() {
        viewModel.viewDidAppear()
    }
}

#endif
