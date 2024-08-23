//
//  Backend.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

extension Backend {
    func validator(_ response: HTTPDataResponse) -> HTTPError? {
        struct ErrorCodesResponse: Decodable /* temp */ {
            let codes: [Code]?

            enum CodingKeys: String, CodingKey {
                case codes = "errors"
            }
        }

        struct Code: Decodable /* temp */ {
            enum CodingKeys: String, CodingKey {
                case value = "code"
            }

            let value: String?
        }

        if let data = response.body, !data.isEmpty {
            if let errorCodes = try? decoder.decode(ErrorCodesResponse.self, from: data).codes, !errorCodes.isEmpty {
                return HTTPError.backend(response, error: ErrorResponse(
                    body: String(data: data, encoding: .utf8) ?? "unknown",
                    errorCodes: errorCodes.compactMap(\.value),
                    requestId: response.headers.getBackendRequestId()
                ))
            }
        }
        return HTTPResponse.statusCodeValidator(response)
    }
}
