//
//  Backend.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

extension Backend {
    private struct ErrorCodesResponse: Decodable {
        let codes: [String]?
        enum CodingKeys: String, CodingKey {
            case array = "errors"
            case code = "error_code"
        }

        struct Code: Decodable {
            enum CodingKeys: String, CodingKey {
                case value = "code"
            }

            let value: String?
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let code = try container.decodeIfPresent(String.self, forKey: .code) {
                self.codes = [code]
            } else {
                let array = try container.decodeIfPresent([Code].self, forKey: .array)
                self.codes = array.map { $0.compactMap(\.value) }
            }
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

        return BackendError(
            body: String(data: data, encoding: .utf8) ?? "unknown",
            errorCodes: errorCodes,
            requestId: response.headers.getBackendRequestId()
        )
    }
}
