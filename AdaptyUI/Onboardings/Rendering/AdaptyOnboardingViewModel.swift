//
//  AdaptyOnboardingViewModel.swift
//  Onboardings
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import Adapty
import Foundation
import WebKit

private extension AdaptyUI {
    static let webViewEventMessageName = "postEvent"
}

final class AdaptyOnboardingViewModel: ObservableObject {
    let stamp: String
    let configuration: AdaptyUI.OnboardingConfiguration
    var onMessage: ((AdaptyOnboardingsMessage) -> Void)?
    var onError: ((AdaptyUIError) -> Void)?

    private let webViewDelegate = AdaptyWebViewDelegate()

    init(stamp: String, configuration: AdaptyUI.OnboardingConfiguration) {
        self.stamp = stamp
        self.configuration = configuration
    }

    @MainActor
    func configureWebView(_ webView: WKWebView) {
        Log.onboardings.verbose("\(stamp) configureWebView \(configuration.url)")

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

        let request = URLRequest(url: configuration.url)
        webView.load(request)
    }

    private func handleMessage(_ name: String, _ body: Any) {
        do {
            let message = try AdaptyOnboardingsMessage(chanel: name, body: body)
            Log.onboardings.verbose("\(stamp) On message: \(message)")

            onMessage?(message)

            switch message {
            case let .analytics(event):
                handleAnalyticsEvent(event, variationId: configuration.variationId)
            default:
                break
            }
        } catch let error as OnboardingsUnknownMessageError {
            Log.onboardings.warn("\(stamp) Unknown message \(error.type.map { "with type \"\($0)\"" } ?? "with name \"\(error.chanel)\""): \(String(describing: body))")
        } catch {
            Log.onboardings.error("\(stamp) Error on decoding event: \(error)")
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

final class AdaptyWebViewDelegate: NSObject {
    var onError: ((Error) -> Void)?
    var onMessage: ((String, Any) -> Void)?
}

extension AdaptyWebViewDelegate: WKNavigationDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        let url = webView.url?.absoluteString ?? "null"
        Log.onboardings.verbose("\(stamp) webView didStartProvisionalNavigation url: \(url)")
    }

    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        let url = webView.url?.absoluteString ?? "null"
        Log.onboardings.verbose("\(stamp) webView didFinish navigation url: \(url)")
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        Log.onboardings.error("\(stamp) didFail navigation withError \(error)")
        onError?(error)
    }

    public func userContentController(_: WKUserContentController, didReceive wkMessage: WKScriptMessage) {
        onMessage?(wkMessage.name, wkMessage.body)
    }
}
