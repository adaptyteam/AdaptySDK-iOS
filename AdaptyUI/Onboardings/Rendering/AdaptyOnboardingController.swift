//
//  AdaptyOnboardingController.swift
//
//
//  Created by Aleksey Goncharov on 02.08.2024.
//

import Adapty
import UIKit
import WebKit

public final class AdaptyOnboardingController: UIViewController {
    var id: UUID { UUID() } // TODO: implement
    var onboarding: AdaptyOnboarding { viewModel.configuration.onboarding } // TODO: maybe public
    
    private let stamp: String
    private let viewModel: AdaptyOnboardingViewModel
    weak var delegate: AdaptyOnboardingControllerDelegate?

    private var webView: WKWebView!

    init(
        configuration: AdaptyUI.OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate
    ) {
        let stamp = Log.stamp

        self.stamp = stamp
        self.delegate = delegate
        self.viewModel = AdaptyOnboardingViewModel(
            stamp: stamp,
            configuration: configuration
        )

        super.init(nibName: nil, bundle: nil)

        viewModel.onMessage = { [weak self] message in
            self?.handleMessage(message)
        }

        viewModel.onError = { [weak self] error in
            self?.handleError(error)
        }
    }

    private func handleMessage(_ message: AdaptyOnboardingsMessage) {
        delegate?.apply(message: message, from: self)
    }

    private func handleError(_ error: AdaptyUIError) {
        delegate?.apply(error: error, from: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let webView = buildWebView()
        layoutWebView(webView)
        self.webView = webView

        viewModel.configureWebView(webView)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }

    private func buildWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)

        return webView
    }

    private func layoutWebView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        view.addConstraints([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
