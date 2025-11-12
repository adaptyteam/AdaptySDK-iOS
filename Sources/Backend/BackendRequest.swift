//
//  BackendRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

protocol BackendRequest: Sendable, HTTPRequest {
    var stamp: String { get }
    var logName: APIRequestName { get }
    var logParams: EventParameters? { get }
}

extension BackendRequest {
    var logParams: EventParameters? { nil }
}

protocol BackendEncodableRequest: BackendRequest, HTTPEncodableRequest {}
