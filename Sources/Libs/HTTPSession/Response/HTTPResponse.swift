//
//  HTTPResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2022.
//

import Foundation

struct HTTPResponse<Body: Sendable>: Sendable {
    let endpoint: HTTPEndpoint
    let statusCode: Int
    let headers: HTTPHeaders
    let body: Body
    let metrics: HTTPMetrics?
}

extension HTTPResponse {
    @inlinable
    func replaceBody<NewBody>(_ newBody: NewBody) -> HTTPResponse<NewBody> {
        HTTPResponse<NewBody>(endpoint: endpoint, statusCode: statusCode, headers: headers, body: newBody, metrics: metrics)
    }

    @inlinable
    func replaceMetrics(_ metrics: HTTPMetrics?) -> Self {
        HTTPResponse(
            endpoint: endpoint,
            statusCode: statusCode,
            headers: headers,
            body: body,
            metrics: metrics
        )
    }

    @inlinable
    func replaceDecodingTime(start: DispatchTime, end: DispatchTime) -> Self {
        guard let metrics else { return self }
        let decoding = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        guard metrics.decoding != decoding else { return self }
        return replaceMetrics(HTTPMetrics(
            taskInterval: metrics.taskInterval,
            redirectCount: metrics.redirectCount,
            transactions: metrics.transactions,
            decoding: decoding
        ))
    }
}
