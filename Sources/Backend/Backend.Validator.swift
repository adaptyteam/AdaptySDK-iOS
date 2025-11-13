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
            case details = "detail"
        }

        struct Code: Decodable {
            enum CodingKeys: String, CodingKey {
                case value = "code"
            }

            let value: String?
        }

        struct Detail: Decodable {
            enum CodingKeys: String, CodingKey {
                case value = "type"
            }

            let value: String
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let code = try container.decodeIfPresent(String.self, forKey: .code) {
                self.codes = [code]
            } else if let details = try container.decodeIfPresent([Detail].self, forKey: .details).nonEmptyOrNil {
                self.codes = details.map(\.value)
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

    private func backendUnavailableError(
        _ response: HTTPDataResponse,
        _ now: Date = Date()
    ) -> BackendUnavailableError? {
        switch response.statusCode {
        case 401: return .unauthorized
        case 429: return .blockedUntil(response.headers.getRetryAfter(now))
        case 444:
            let seconds = response.body
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap(Double.init)
                .map { $0 * 60 }
            return .blockedUntil(now.addingTimeInterval(seconds ?? (24 * 60 * 60))) // 24h
        default:
            return nil
        }
    }

    @Sendable
    func validator(_ response: HTTPDataResponse) -> Error? {
        if let data = response.body.nonEmptyOrNil,
           let errorCodes = try? errorCodesResponse(from: data, withConfiguration: defaultHTTPConfiguration).codes.nonEmptyOrNil
        {
            BackendError(
                body: String(data: data, encoding: .utf8) ?? "unknown",
                errorCodes: errorCodes,
                requestId: response.headers.getBackendRequestId()
            )
        } else if let error = backendUnavailableError(response) {
            error
        } else {
            HTTPResponse.statusCodeValidator(response)
        }
    }
}
