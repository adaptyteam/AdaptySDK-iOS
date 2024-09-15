//
//  Backend.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

extension Backend {
    private struct ErrorCodesResponse: Decodable /* temp */ {
        let codes: [Code]?
        enum CodingKeys: String, CodingKey {
            case codes = "errors"
        }

        struct Code: Decodable /* temp */ {
            enum CodingKeys: String, CodingKey {
                case value = "code"
            }

            let value: String?
        }
    }

    private func errorCodesResponse(
        from data: Data,
        withConfiguration configuration: HTTPCodableConfiguration
    ) throws -> ErrorCodesResponse {
        let jsonDecoder = JSONDecoder()
        configuration.configure(jsonDecoder: jsonDecoder)
        return try jsonDecoder.decode(ErrorCodesResponse.self, from: data)
    }

    @Sendable
    func validator(_ response: HTTPDataResponse) -> Error? {
        guard let data = response.body, !data.isEmpty,
              let errorCodes = try? errorCodesResponse(from: data, withConfiguration: self).codes, !errorCodes.isEmpty
        else {
            return HTTPResponse.statusCodeValidator(response)
        }

        return HTTPError.backend(response, error: BackendError(
            body: String(data: data, encoding: .utf8) ?? "unknown",
            errorCodes: errorCodes.compactMap(\.value),
            requestId: response.headers.getBackendRequestId()
        ))
    }
}
