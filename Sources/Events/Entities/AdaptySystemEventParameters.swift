//
//  AdaptySystemEventParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.03.2023
//

import Foundation

protocol AdaptySystemEventParameters: Encodable {}

private enum CodingKeys: String, CodingKey {
    case name = "event_name"
    case callId = "sdk_flow_id"
    case requestData = "request_data"
    case responseData = "response_data"
    case eventData = "event_data"

    case backendRequestId = "api_request_id"
    case success
    case error
}

typealias EventParameters = [String: AnyEncodable?]

struct AdaptySDKMethodRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let params: EventParameters?

    init(methodName: String, callId: String, params: EventParameters? = nil) {
        self.methodName = methodName
        self.callId = callId
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_request_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try encoder.encode(params)
    }
}

struct AdaptySDKMethodResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String?
    let params: EventParameters?
    let error: String?

    init(methodName: String, callId: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.methodName = methodName
        self.callId = callId
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("sdk_response_\(methodName)", forKey: .name)
        try container.encodeIfPresent(callId, forKey: .callId)
        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
        try encoder.encode(params)
    }
}

struct AdaptyBackendAPIRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let params: EventParameters?

    init(methodName: String, callId: String, params: EventParameters? = nil) {
        self.methodName = methodName
        self.callId = callId
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_request_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try encoder.encode(params)
    }
}

struct AdaptyBackendAPIResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String
    let backendRequestId: String?
    let error: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("api_response_\(methodName)", forKey: .name)
        try container.encode(callId, forKey: .callId)
        try container.encodeIfPresent(backendRequestId, forKey: .backendRequestId)

        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
    }

    init(methodName: String, callId: String, backendRequestId: String?, error: String?) {
        self.methodName = methodName
        self.callId = callId
        self.backendRequestId = backendRequestId
        self.error = error
    }

    init(methodName: String, callId: String, _ result: HTTPResponse<some Any>.Result) {
        switch result {
        case let .failure(error):
            self.init(methodName: methodName, callId: callId, backendRequestId: error.headers?.getBackendRequestId(), error: error.description)
        case let .success(response):
            self.init(methodName: methodName, callId: callId, backendRequestId: response.headers.getBackendRequestId(), error: nil)
        }
    }
}

struct AdaptyAppleRequestParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String?
    let params: EventParameters?

    init(methodName: String, callId: String? = nil, params: EventParameters? = nil) {
        self.methodName = methodName
        self.callId = callId
        self.params = params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_request_\(methodName)", forKey: .name)
        try container.encodeIfPresent(callId, forKey: .callId)
        try encoder.encode(params)
    }
}

struct AdaptyAppleResponseParameters: AdaptySystemEventParameters {
    let methodName: String
    let callId: String?
    let params: EventParameters?
    let error: String?

    init(methodName: String, callId: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.methodName = methodName
        self.callId = callId
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_response_\(methodName)", forKey: .name)
        try container.encodeIfPresent(callId, forKey: .callId)
        try encoder.encode(params)
        if let error {
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        } else {
            try container.encode(true, forKey: .success)
        }
    }
}

struct AdaptyAppleEventQueueHandlerParameters: AdaptySystemEventParameters {
    let eventName: String
    let callId: String?
    let params: EventParameters?
    let error: String?

    init(eventName: String, callId: String? = nil, params: EventParameters? = nil, error: String? = nil) {
        self.eventName = eventName
        self.callId = callId
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("apple_event_\(eventName)", forKey: .name)
        try container.encodeIfPresent(callId, forKey: .callId)
        try encoder.encode(params)
        if let error {
            try container.encode(error, forKey: .error)
        }
    }
}

struct AdaptyInternalEventParameters: AdaptySystemEventParameters {
    let eventName: String
    let params: EventParameters?
    let error: String?

    init(eventName: String, params: EventParameters? = nil, error: String? = nil) {
        self.eventName = eventName
        self.params = params
        self.error = error
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("internal_\(eventName)", forKey: .name)
        try encoder.encode(params)
        if let error {
            try container.encode(error, forKey: .error)
        }
    }
}

private extension Encoder {
    func encode(_ params: EventParameters?) throws {
        guard let params else { return }
        var container = container(keyedBy: AnyCodingKeys.self)
        try params.forEach {
            guard let value = $1 else { return }
            try container.encode(value, forKey: AnyCodingKeys(stringValue: $0))
        }
    }
}
