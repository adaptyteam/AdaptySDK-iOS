//
//  HTTPSession+trackSystemEvent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

extension HTTPSession {
    @inlinable
    func perform<Request: HTTPRequestWithDecodableResponse>(
        _ request: Request,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> Request.Response {
        let stamp = request.stamp
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: Request.Response = try await perform(request)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }

    @inlinable
    func perform(
        _ request: some HTTPRequest,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> HTTPEmptyResponse {
        let stamp = request.stamp
        Adapty.trackSystemEvent(AdaptyBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: HTTPEmptyResponse = try await perform(request)
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Adapty.trackSystemEvent(AdaptyBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }
}
