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
    fileprivate static let viewConfigurationLocaleHeaderKey = "adapty-paywall-builder-locale"
    fileprivate static let visualBuilderVersionHeaderKey = "adapty-paywall-builder-version"
    fileprivate static let visualBuilderConfigurationFormatVersionHeaderKey = "adapty-paywall-builder-config-format-version"
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

    static func globalHeaders(with config: Adapty.Configuration) -> HTTPHeaders {
        var headers = [
            authorizationHeaderKey: "Api-Key \(config.apiKey)",
            sdkVersionHeaderKey: Adapty.SDKVersion,
            sdkPlatformHeaderKey: Environment.System.name,
            sdkStoreHeaderKey: "app_store",
            sessionIDHeaderKey: Environment.Application.sessionIdentifier,
            appInstallIdHeaderKey: Environment.Application.installationIdentifier,
            isSandboxHeaderKey: Environment.System.isSandbox ? "true" : "false",
            isObserveModeHeaderKey: config.observerMode ? "true" : "false",
            storeKit2EnabledHeaderKey: Environment.System.storeKit2Enabled ? "enabled" : "unavailable",
        ]
        if let ver = Environment.Application.version {
            headers[appVersionHeaderKey] = ver
        }

        if let crossPlatform = config.crossPlatformSDK {
            headers[crossSDKPlatformHeaderKey] = crossPlatform.name
            headers[crossSDKVersionHeaderKey] = crossPlatform.version
        }

        return headers
    }
}

extension Backend.Response {
    fileprivate static let hashHeaderKey = "x-response-hash"
    fileprivate static let requestIdHeaderKey = "request-id"
}

extension HTTPHeaders {
    func setPaywallLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.paywallLocaleHeaderKey)
    }

    func setViewConfigurationLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.viewConfigurationLocaleHeaderKey)
    }

    func setVisualBuilderVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.visualBuilderVersionHeaderKey)
    }

    func setVisualBuilderConfigurationFormatVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.visualBuilderConfigurationFormatVersionHeaderKey)
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
