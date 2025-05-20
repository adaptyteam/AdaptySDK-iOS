//
//  AdaptyOnboardingViewModel.swift
//  Onboardings
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation
import WebKit

private extension AdaptyUI {
    static let webViewEventMessageName = "postEvent"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
final class AdaptyOnboardingViewModel: ObservableObject {
    let logId: String
    let onboarding: AdaptyOnboarding
    var onMessage: ((AdaptyOnboardingsMessage) -> Void)?
    var onError: ((AdaptyUIError) -> Void)?

    private let webViewDelegate: AdaptyWebViewDelegate

    init(logId: String, onboarding: AdaptyOnboarding) {
        self.logId = logId
        self.onboarding = onboarding
        self.webViewDelegate = AdaptyWebViewDelegate(logId: logId)
    }

    private weak var webView: WKWebView?

    @MainActor
    func configureWebView(_ webView: WKWebView) {
        Log.onboardings.verbose("\(logId) configureWebView \(onboarding.viewConfiguration.url)")

        webViewDelegate.onMessage = { [weak self] name, body in
            self?.handleMessage(name, body)
        }
        webViewDelegate.onError = { [weak self] error in
            self?.onError?(.webKit(error))
        }

        webView.navigationDelegate = webViewDelegate
        webView.configuration.userContentController.add(
            webViewDelegate,
            name: AdaptyUI.webViewEventMessageName
        )

        self.webView = webView
    }

    private var wasAppeared: Bool = false
    private var wasLoaded: Bool = false
    private var persistWasCalled: Bool = false

    func viewDidAppear() {
        Log.ui.verbose("VM #\(logId)# viewDidAppear")

        if !wasAppeared {
            let request = URLRequest(url: onboarding.viewConfiguration.url)
            webView?.load(request)
        }
        
        wasAppeared = true
        persistOnboardingVariationIdIfNeeded()
    }

    func viewDidDisappear() {
        Log.ui.verbose("VM #\(logId)# viewDidDisappear")
    }

    private func handleMessage(_ name: String, _ body: Any) {
        do {
            let message = try AdaptyOnboardingsMessage(chanel: name, body: body)
            Log.onboardings.verbose("VM \(logId) On message: \(message)")

            onMessage?(message)

            switch message {
            case .didFinishLoading:
                wasLoaded = true
                persistOnboardingVariationIdIfNeeded()
            case let .analytics(event):
                handleAnalyticsEvent(event, variationId: onboarding.variationId)
            default:
                break
            }
        } catch let error as OnboardingsUnknownMessageError {
            Log.onboardings.warn("VM \(logId) Unknown message \(error.type.map { "with type \"\($0)\"" } ?? "with name \"\(error.chanel)\""): \(String(describing: body))")
        } catch {
            Log.onboardings.error("VM \(logId) Error on decoding event: \(error)")
        }
    }

    private func persistOnboardingVariationIdIfNeeded() {
        guard onboarding.shouldTrackShown, wasAppeared, wasLoaded else { return }

        let variationId = onboarding.variationId

        Task { @MainActor in
            guard !persistWasCalled else { return }

            await Adapty.persistOnboardingVariationId(variationId)

            Log.onboardings.verbose("VM \(logId) persistOnboardingVariationId")
            persistWasCalled = true
        }
    }

    private func handleAnalyticsEvent(_ event: AdaptyOnboardingsAnalyticsEvent, variationId: String) {
        Task {
            switch event {
            case let .screenPresented(meta):
                let isLatest = meta.screenIndex == meta.screensTotal - 1
                let params = AdaptyOnboardingScreenShowedParameters(
                    variationId: variationId,
                    screenName: meta.screenClientId,
                    screenOrder: "\(meta.screenIndex)",
                    isLatestScreen: isLatest
                )
                try await Adapty.logShowOnboarding(params)
            default:
                break
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
final class AdaptyWebViewDelegate: NSObject {
    let logId: String

    var onError: ((Error) -> Void)?
    var onMessage: ((String, Any) -> Void)?

    init(logId: String) {
        self.logId = logId

        super.init()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyWebViewDelegate: WKNavigationDelegate, WKScriptMessageHandler {
    public func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation _: WKNavigation!
    ) {
        let url = webView.url?.absoluteString ?? "null"
        Log.onboardings.verbose("\(logId) webView didStartProvisionalNavigation url: \(url)")
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation _: WKNavigation!,
        withError error: any Error
    ) {
        let url = webView.url?.absoluteString ?? "null"

        Log.onboardings.error("\(logId) webView didFailProvisionalNavigation with url: \(url), error: \(error)")
        onError?(error)
    }

    public func webView(
        _ webView: WKWebView,
        didFinish _: WKNavigation!
    ) {
        let url = webView.url?.absoluteString ?? "null"
        Log.onboardings.verbose("\(logId) webView didFinish navigation url: \(url)")
    }

    public func webView(
        _: WKWebView,
        didFail _: WKNavigation!,
        withError error: Error
    ) {
        Log.onboardings.error("\(logId) didFail navigation withError \(error)")
        onError?(error)
    }

    public func userContentController(
        _: WKUserContentController,
        didReceive wkMessage: WKScriptMessage
    ) {
        onMessage?(wkMessage.name, wkMessage.body)
    }
}

#endif
