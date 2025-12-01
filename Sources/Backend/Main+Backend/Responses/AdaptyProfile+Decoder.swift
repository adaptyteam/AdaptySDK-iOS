//
//  AdaptyProfile+Decoder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

extension VH<AdaptyProfile> {
    static func decoder(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) async throws -> HTTPResponse<VH<AdaptyProfile>> {
        let body = try response.decodeBody(Backend.Response.Data<AdaptyProfile>.self, with: configuration)
        return response.replaceBody(VH(body.value, hash: response.headers.getBackendResponseHash()))
    }
}

extension VH<AdaptyProfile>? {
    static func decoder(
        _ response: HTTPDataResponse,
        _ configuration: HTTPCodableConfiguration?,
        _ request: HTTPRequest
    ) async throws -> HTTPResponse<VH<AdaptyProfile>?> {
        guard !request.headers.hasSameBackendResponseHash(response.headers) else {
            return response.replaceBody(nil)
        }
        let body = try response.decodeBody(Backend.Response.Data<AdaptyProfile>.self, with: configuration)
        return response.replaceBody(VH(body.value, hash: response.headers.getBackendResponseHash()))
    }
}
