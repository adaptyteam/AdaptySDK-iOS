//
//  AdaptyPlugin+NativeViewRequest.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/30/25.
//

import Adapty
import Foundation

private let log = Log.plugin

extension Request {
    struct AdaptyUICreateNativeOnboardingView: Decodable {
        static let method = "adapty_ui_create_native_onboarding_view"

        let onboarding: AdaptyOnboarding

        enum CodingKeys: String, CodingKey {
            case onboarding
        }
    }
}

// TODO: refactor this
public extension AdaptyPlugin {
    static func executeCreateNativeOnboardingView(withJson jsonString: AdaptyJsonString) async -> AdaptyOnboarding? {
        do {
            let request = try AdaptyPlugin.decoder.decode(
                Request.AdaptyUICreateNativeOnboardingView.self,
                from: jsonString.asAdaptyJsonData
            )
            return request.onboarding
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method:\(Request.AdaptyUICreateNativeOnboardingView.method) is invalid", error)
            log.error(error.message)
            return nil
        }
    }
}
