//
//  BackendExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

protocol BackendExecutor: Sendable {
    var session: HTTPSession { get }
}

protocol BackendAPIRequestParameters: Sendable {
    var logName: APIRequestName { get }
    var stamp: String { get }
    var logParams: EventParameters? { get }
}

extension BackendExecutor {
    @AdaptyActor
    @inlinable
    func perform<Request: HTTPRequestWithDecodableResponse & BackendAPIRequestParameters>(
        _ request: Request
    ) async throws -> Request.Response {
        try await perform(request, requestName: request.logName, logParams: request.logParams)
    }

    @AdaptyActor
    @inlinable
    func perform<Request: HTTPRequestWithDecodableResponse>(
        _ request: Request,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> Request.Response {
        let stamp = request.stamp
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: Request.Response = try await session.perform(request)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }

    @AdaptyActor
    @inlinable
    func perform<Request: HTTPRequest & BackendAPIRequestParameters>(
        _ request: Request
    ) async throws -> HTTPEmptyResponse {
        try await perform(request, requestName: request.logName, logParams: request.logParams)
    }

    @AdaptyActor
    @inlinable
    func perform(
        _ request: some HTTPRequest,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> HTTPEmptyResponse {
        let stamp = request.stamp
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: HTTPEmptyResponse = try await session.perform(request)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }

    @AdaptyActor
    @inlinable
    func perform<Body, Request: HTTPRequest & BackendAPIRequestParameters>(
        _ request: Request,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws -> HTTPResponse<Body> {
        try await perform(request, requestName: request.logName, logParams: request.logParams, withDecoder: decoder)
    }

    @AdaptyActor
    @inlinable
    func perform<Body>(
        _ request: some HTTPRequest,
        requestName: APIRequestName,
        logParams: EventParameters? = nil,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws -> HTTPResponse<Body> {
        let stamp = request.stamp
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: HTTPResponse<Body> = try await session.perform(request, withDecoder: decoder)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }
}
