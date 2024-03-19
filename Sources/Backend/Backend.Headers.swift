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
    fileprivate static let adaptyUISDKVersionHeaderKey = "adapty-ui-version"
    fileprivate static let visualBuilderVersion = "adapty-paywall-builder-version"

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

    static func globalHeaders(secretKey: String) -> HTTPRequest.Headers {
        var headers = [
            authorizationHeaderKey: "Api-Key \(secretKey)",
            sdkVersionHeaderKey: Adapty.SDKVersion,
            sdkPlatformHeaderKey: Environment.System.name,
            sdkStoreHeaderKey: "app_store",
            sessionIDHeaderKey: Environment.Application.sessionIdentifier,
            appInstallIdHeaderKey: Environment.Application.installationIdentifier,
            isSandboxHeaderKey: Environment.System.isSandbox ? "true" : "false",
            isObserveModeHeaderKey: Adapty.Configuration.observerMode ? "true" : "false",
            storeKit2EnabledHeaderKey: Adapty.Configuration.storeKit2Enabled,
        ]
        if let ver = Environment.Application.version {
            headers[appVersionHeaderKey] = ver
        }
        if let ver = Environment.CrossPlatformSDK.version {
            headers[crossSDKVersionHeaderKey] = ver
        }
        if let name = Environment.CrossPlatformSDK.name {
            headers[crossSDKPlatformHeaderKey] = name
        }
        return headers
    }
}

extension Backend.Response {
    fileprivate static let hashHeaderKey = "x-response-hash"
    fileprivate static let requestIdHeaderKey = "request-id"
}

extension [HTTPRequest.Headers.Key: HTTPRequest.Headers.Value] {
    func setPaywallLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.paywallLocaleHeaderKey)
    }

    func setViewConfigurationLocale(_ locale: AdaptyLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.viewConfigurationLocaleHeaderKey)
    }

    func setAdaptyUISDKVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.adaptyUISDKVersionHeaderKey)
    }

    func setVisualBuilderVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.visualBuilderVersion)
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

    func hasSameBackendResponseHash(_ responseHeaders: HTTPResponseHeaders) -> Bool {
        guard let requestHash = self[Backend.Request.hashHeaderKey],
              let responseHash = responseHeaders.getBackendResponseHash(),
              requestHash == responseHash
        else { return false }
        return true
    }
}

extension HTTPResponseHeaders {
    func getBackendResponseHash() -> String? {
        let value = self[Backend.Response.hashHeaderKey] as? String
        return value
    }

    func getBackendRequestId() -> String? {
        let value = self[Backend.Response.requestIdHeaderKey] as? String
        return value
    }
}
