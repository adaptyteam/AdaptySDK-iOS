//
//  BackendExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

@BackendActor
protocol BackendExecutor: Sendable {
    var session: HTTPSession { get }
    nonisolated var baseURLFor: @BackendActor (BackendRequest) async throws -> URL { get }
}

protocol BackendRequest: Sendable, HTTPRequest {
    var stamp: String { get }
    var logName: APIRequestName { get }
    var logParams: EventParameters? { get }
}

extension BackendRequest {
    var logParams: EventParameters? { nil }
}

protocol BackendEncodableRequest: BackendRequest, HTTPEncodableRequest {}

extension BackendExecutor {
    @BackendActor
    @inlinable
    func perform(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPEmptyResponse {
        try await perform(request, withDecoder: HTTPEmptyResponse.defaultDecoder)
    }

    @BackendActor
    @inlinable
    func perform<Body: Decodable & Sendable>(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        try await perform(request, withDecoder: HTTPDataResponse.defaultDecoder)
    }

    @BackendActor
    @inlinable
    func perform<Body>(
        _ request: some BackendRequest,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        let stamp = request.stamp
        let requestName = request.logName
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: request.logParams))

        let baseUrl: URL
        do {
            baseUrl = try await baseURLFor(request)
        } catch {
            let error = HTTPError.perform(request.endpoint, error: error)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }

        do {
            let response: HTTPResponse<Body> = try await session.perform(request, withBaseUrl: baseUrl, withDecoder: decoder)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }
}
