//
//  BackendExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

private let log = Log.http

@BackendActor
protocol BackendExecutor: Sendable {
    var manager: Backend.StateManager { get }
    var session: HTTPSession { get }
    var kind: AdaptyServerKind { get }
}

extension BackendExecutor {
    @BackendActor
    @inlinable
    func perform(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPEmptyResponse {
        try await perform(request, withDecoder: HTTPEmptyResponse.emptyBodyDecoder)
    }

    @BackendActor
    @inlinable
    func perform(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPDataResponse {
        try await perform(request, withDecoder: HTTPDataResponse.dataDecoder)
    }

    @BackendActor
    @inlinable
    func perform(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPStringResponse {
        try await perform(request, withDecoder: HTTPStringResponse.stringDecoder)
    }

    @BackendActor
    @inlinable
    func perform<Body: Decodable & Sendable>(
        _ request: some BackendRequest
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        try await perform(request, withDecoder: HTTPDecodableResponse.decodableBodyDecoder)
    }

    @BackendActor
    @inlinable
    func perform<Body>(
        _ request: some BackendRequest,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        let stamp = request.stamp

        let baseUrl: URL
        do {
            baseUrl = try await manager.baseUrl(request, for: kind)
        } catch {
            let endpoint = request.endpoint
            log.verbose("BLOCKED \(error) <-- \(endpoint.method) \(endpoint.path) [\(stamp)] \(request.logParams ?? [:])")
            throw HTTPError.perform(request.endpoint, error: error)
        }

        do {
            return try await DefaultBackendExecutor.perform(
                request,
                withBaseUrl: baseUrl,
                withSession: session,
                withDecoder: decoder
            )
        } catch {
            manager.handleNetworkState(kind, request.requestName, baseUrl, error)
            throw error
        }
    }
}

enum DefaultBackendExecutor {
    @BackendActor
    @inlinable
    static func perform<Body>(
        _ request: some BackendRequest,
        withBaseUrl baseUrl: URL,
        withSession session: HTTPSession,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        let stamp = request.stamp
        let requestName = request.requestName

        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: request.logParams))
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
