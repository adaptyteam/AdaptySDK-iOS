//
//  BackendIntroductoryOfferEligibilityState+Decoder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

extension [BackendIntroductoryOfferEligibilityState]? {
    static func decoder(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) async throws -> HTTPResponse<[BackendIntroductoryOfferEligibilityState]?> {
        guard !request.headers.hasSameBackendResponseHash(response.headers) else {
            return response.replaceBody(nil)
        }
        let body = try response.decodeBody(Backend.Response.Data<[BackendIntroductoryOfferEligibilityState]>.self, with: configuration)
        return response.replaceBody(body.value)
    }
}
