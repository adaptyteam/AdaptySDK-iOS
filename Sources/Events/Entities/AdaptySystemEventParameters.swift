//
//  AdaptySystemEventParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.03.2023
//

import Foundation

protocol AdaptySystemEventParameters: Encodable {}

fileprivate enum CodingKeys: String, CodingKey {
    case name = "event_name"
    case callId = "sdk_flow_id"
    case requestData = "request_data"
    case responseData = "response_data"
    case eventData = "event_data"

    case backendRequestId = "api_request_id"
    case isError = "is_error"
    case error
}

struct AdaptySDKMethodRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_method_request_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
    }
}

struct AdaptySDKMethodResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_method_response_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        if let error = error {
            try container.encode(true, forKey: .isError)
            try container.encode(error, forKey: .error)
        }
    }
}

struct AdaptyBackendAPIRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_method_request_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
    }
}

struct AdaptyBackendAPIResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let backendRequestId: String?
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_method_response_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try container.encodeIfPresent(backendRequestId, forKey: .backendRequestId)

        if let error = error {
            try container.encode(true, forKey: .isError)
            try container.encode(error, forKey: .error)
        }
    }
}

struct AdaptyAppleRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let data: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_method_request_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try container.encode(data, forKey: .requestData)
    }
}

struct AdaptyAppleResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let data: String
    var isError: Bool { error != nil }
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_method_response_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try container.encode(data, forKey: .responseData)
        if let error = error {
            try container.encode(true, forKey: .isError)
            try container.encode(error, forKey: .error)
        }
    }
}

struct AdaptyAppleEventQueueHandlerParameters: AdaptySystemEventParameters {
    let eventName: String
    let data: String
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_event_queue_handler_\(eventName)", forKey: .name)
        try container.encode(data, forKey: .eventData)
        if let error = error {
            try container.encode(true, forKey: .isError)
            try container.encode(error, forKey: .error)
        }
    }
}
