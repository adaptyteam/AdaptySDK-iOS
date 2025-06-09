//
//  Backend.Headers.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend.Request {
    fileprivate static let authorizationHeaderKey = "Authorization"
    fileprivate static let hashHeaderKey = "adapty-sdk-previous-response-hash"
    fileprivate static let paywallLocaleHeaderKey = "adapty-paywall-locale"
    fileprivate static let onboardingLocaleHeaderKey = "adapty-onboarding-locale"
    fileprivate static let paywallBuilderLocaleHeaderKey = "adapty-paywall-builder-locale"
    fileprivate static let paywallBuilderVersionHeaderKey = "adapty-paywall-builder-version"
    fileprivate static let paywallBuilderConfigurationFormatVersionHeaderKey = "adapty-paywall-builder-config-format-version"
    fileprivate static let onboardingUIVersionHeaderKey = "adapty-onboarding-ui-version"
    fileprivate static let crossPlacementEligibilityHeaderKey = "adapty-cross-placement-eligibility"
    fileprivate static let segmentIdHeaderKey = "adapty-profile-segment-hash"

    fileprivate static let profileIdHeaderKey = "adapty-sdk-profile-id"
    fileprivate static let sdkVersionHeaderKey = "adapty-sdk-version"
    fileprivate static let sdkPlatformHeaderKey = "adapty-sdk-platform"
    fileprivate static let sdkStoreHeaderKey = "adapty-sdk-store"
    fileprivate static let sessionIDHeaderKey = "adapty-sdk-session"
    fileprivate static let appVersionHeaderKey = "adapty-app-version"

    fileprivate static let isSandboxHeaderKey = "adapty-sdk-sandbox-mode-enabled"
    fileprivate static let isObserveModeHeaderKey = "adapty-sdk-observer-mode-enabled"
    fileprivate static let storeKit2EnabledHeaderKey = "adapty-sdk-storekit2-enabled"
    fileprivate static let appInstallIdHeaderKey = "adapty-sdk-device-id"
    fileprivate static let crossSDKVersionHeaderKey = "adapty-sdk-crossplatform-version"
    fileprivate static let crossSDKPlatformHeaderKey = "adapty-sdk-crossplatform-name"

    static func globalHeadersWithStoreKit(_ configuration: AdaptyConfiguration, _ environment: Environment) -> HTTPHeaders {
        var headers = globalHeaders(configuration, environment)
        headers[sdkStoreHeaderKey] = Environment.StoreKit.name
        headers[isObserveModeHeaderKey] = configuration.observerMode ? "true" : "false"
        headers[storeKit2EnabledHeaderKey] = Environment.StoreKit.storeKit2Enabled ? "enabled" : "unavailable"
        return headers
    }

    static func globalHeaders(_ configuration: AdaptyConfiguration, _ environment: Environment) -> HTTPHeaders {
        var headers = [
            authorizationHeaderKey: "Api-Key \(configuration.apiKey)",
            sdkVersionHeaderKey: Adapty.SDKVersion,
            sdkPlatformHeaderKey: environment.system.name,
            sessionIDHeaderKey: environment.sessionIdentifier,
            appInstallIdHeaderKey: environment.application.installationIdentifier,
        ]

        if let ver = environment.application.version {
            headers[appVersionHeaderKey] = ver
        }

        if let crossPlatformSDK = configuration.crossPlatformSDK {
            headers[crossSDKPlatformHeaderKey] = crossPlatformSDK.name
            headers[crossSDKVersionHeaderKey] = crossPlatformSDK.version
        }

        return headers
    }
}

private extension Backend.Response {
    static let hashHeaderKey = "x-response-hash"
    static let requestIdHeaderKey = "request-id"
}

extension HTTPHeaders {
    func setPaywallLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.paywallLocaleHeaderKey)
    }

    func setOnboardingLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.onboardingLocaleHeaderKey)
    }

    func setPaywallBuilderLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.paywallBuilderLocaleHeaderKey)
    }

    func setPaywallBuilderVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.paywallBuilderVersionHeaderKey)
    }

    func setPaywallBuilderConfigurationFormatVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.paywallBuilderConfigurationFormatVersionHeaderKey)
    }

    func setOnboardingUIVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.onboardingUIVersionHeaderKey)
    }

    func setCrossPlacementEligibility(_ enabled: Bool) -> Self {
        updateOrRemoveValue(enabled ? "true" : "false", forKey: Backend.Request.crossPlacementEligibilityHeaderKey)
    }

    func setSegmentId(_ id: String?) -> Self {
        updateOrRemoveValue(id, forKey: Backend.Request.segmentIdHeaderKey)
    }

    func setBackendResponseHash(_ hash: String?) -> Self {
        updateOrRemoveValue(hash, forKey: Backend.Request.hashHeaderKey)
    }

    func setBackendProfileId(_ profileId: String?) -> Self {
        updateOrRemoveValue(profileId, forKey: Backend.Request.profileIdHeaderKey)
    }

    private func updateOrRemoveValue(_ value: String?, forKey key: String) -> Self {
        var headers = self
        if let value {
            headers.updateValue(value, forKey: key)
        } else {
            headers.removeValue(forKey: key)
        }
        return headers
    }

    func hasSameBackendResponseHash(_ responseHeaders: HTTPHeaders) -> Bool {
        guard let requestHash = self[Backend.Request.hashHeaderKey],
              let responseHash = responseHeaders.getBackendResponseHash(),
              requestHash == responseHash
        else { return false }
        return true
    }
}

extension HTTPHeaders {
    func getBackendResponseHash() -> String? {
        value(forHTTPHeaderField: Backend.Response.hashHeaderKey)
    }

    func getBackendRequestId() -> String? {
        value(forHTTPHeaderField: Backend.Response.requestIdHeaderKey)
    }
}
