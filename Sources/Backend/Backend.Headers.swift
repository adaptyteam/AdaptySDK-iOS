//
//  Backend.Headers.swift
//  Adapty
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend.Request {
    fileprivate static let authorizationHeaderKey = "Authorization"
    fileprivate static let hashHeaderKey = "adapty-sdk-previous-response-hash"
    fileprivate static let profileIdHeaderKey = "adapty-sdk-profile-id"
    fileprivate static let sdkVersionHeaderKey = "adapty-sdk-version"
    fileprivate static let sdkPlatformHeaderKey = "adapty-sdk-platform"
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
            sessionIDHeaderKey: Environment.Application.sessionIdentifier,
            appInstallIdHeaderKey: Environment.Application.installationIdentifier,
            isSandboxHeaderKey: Environment.System.isSandbox ? "true" : "false",
            isObserveModeHeaderKey: Adapty.Configuration.observerMode ? "true" : "false",
            storeKit2EnabledHeaderKey: Adapty.Configuration.useStoreKit2Configuration,
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
    fileprivate static let requestIdHeaderKey = "Request-Id"
}

extension Dictionary where Key == HTTPRequest.Headers.Key, Value == HTTPRequest.Headers.Value {
    func setBackendResponseHash(_ hash: String?) -> Self {
        var headers = self
        if let hash = hash {
            headers.updateValue(hash, forKey: Backend.Request.hashHeaderKey)
        } else {
            headers.removeValue(forKey: Backend.Request.hashHeaderKey)
        }
        return headers
    }

    func setBackendProfileId(_ profileId: String?) -> Self {
        var headers = self
        if let profileId = profileId {
            headers.updateValue(profileId, forKey: Backend.Request.profileIdHeaderKey)
        } else {
            headers.removeValue(forKey: Backend.Request.profileIdHeaderKey)
        }
        return headers
    }

    func hasSameBackendResponseHash(_ responseHeaders: [AnyHashable: Any]) -> Bool {
        guard let requestHash = self[Backend.Request.hashHeaderKey],
              let responseHash = responseHeaders.getBackendResponseHash(),
              requestHash == responseHash
        else { return false }
        return true
    }
}

extension Dictionary where Key == HTTPResponse.Headers.Key, Value == HTTPResponse.Headers.Value {
    func getBackendResponseHash() -> String? {
        let value = self[Backend.Response.hashHeaderKey] as? String
        return value
    }

    func getBackendRequestId() -> String? {
        let value = self[Backend.Response.requestIdHeaderKey] as? String
        return value
    }
}
