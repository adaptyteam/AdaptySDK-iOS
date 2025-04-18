//
//  OnboardingViewModel.swift
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

final class OnboardingViewModel: NSObject, ObservableObject {
    let stamp: String
    let configuration: AdaptyUI.OnboardingConfiguration
    var onMessage: ((OnboardingsMessage) -> Void)?
    var onError: ((AdaptyUIError) -> Void)?

    init(stamp: String, configuration: AdaptyUI.OnboardingConfiguration) {
        self.stamp = stamp
        self.configuration = configuration
    }

    @MainActor
    func configureWebView(_ webView: WKWebView) {
        Log.onboardings.verbose("\(stamp) configureWebView \(configuration.url)")

        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: AdaptyUI.webViewEventMessageName)

        let request = URLRequest(url: configuration.url)
        webView.load(request)
    }
}

extension OnboardingViewModel: WKNavigationDelegate, WKScriptMessageHandler {
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
        onError?(.webKit(error))
    }

    public func userContentController(_: WKUserContentController, didReceive wkMessage: WKScriptMessage) {
        do {
            let message = try OnboardingsMessage(chanel: wkMessage.name, body: wkMessage.body)
            Log.onboardings.verbose("\(stamp) On message: \(message)")
            onMessage?(message)
        } catch let error as OnboardingsUnknownMessageError {
            Log.onboardings.warn("\(stamp) Unknown message \(error.type.map { "with type \"\($0)\"" } ?? "with name \"\(error.chanel)\""): \(String(describing: wkMessage.body))")
        } catch {
            Log.onboardings.error("\(stamp) Error on decoding event: \(error)")
        }
    }
}
