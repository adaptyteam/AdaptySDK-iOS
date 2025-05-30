//
//  AdaptyPlugin+NativeViewRequest.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/30/25.
//

import Adapty
import Foundation

private let log = Log.plugin

// TODO: refactor this
public extension AdaptyPlugin {
    static func executeCreateNativeOnboardingView(withJson jsonString: AdaptyJsonString) async -> AdaptyOnboarding? {
        do {
            return try AdaptyPlugin.decoder.decode(
                AdaptyOnboarding.self,
                from: jsonString.asAdaptyJsonData
            )
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method: create_native_onboarding_view is invalid", error)
            log.error(error.message)
            return nil
        }
    }
}
