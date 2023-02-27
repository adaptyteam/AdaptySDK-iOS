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
    fileprivate static let platformHeaderKey = "adapty-sdk-platform"
    static let sessionIDHeaderKey = "adapty-sdk-session-id"

    static func globalHeaders(secretKey: String) -> HTTPRequest.Headers { [
        authorizationHeaderKey: "Api-Key \(secretKey)",
        sdkVersionHeaderKey: Adapty.SDKVersion,
        platformHeaderKey: Environment.System.name,
    ] }
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
