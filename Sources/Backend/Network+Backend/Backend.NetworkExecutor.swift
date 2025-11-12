//
//  Backend.NetworkExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.11.2025.
//

import Foundation

extension Backend {
    struct NetworkExecutor {
        let baseUrl: URL
        let session: HTTPSession
        let kind: AdaptyServerKind
    }
}

extension Backend.NetworkExecutor {
    @BackendActor
    @inlinable
    func perform<Body: Decodable & Sendable>(
        _ request: some BackendRequest,
        withBaseUrl baseUrl: URL
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        try await DefaultBackendExecutor.perform(
            request,
            withBaseUrl: baseUrl,
            withSession: session,
            withDecoder: HTTPDataResponse.defaultDecoder
        )
    }
}
