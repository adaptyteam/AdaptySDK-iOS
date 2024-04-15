//
//  Backend.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

extension Backend {
    private struct _ErrorResponse: Decodable {
        let errors: [Error]?
        struct Error: Decodable {
            let code: String?
        }
    }

    func validator(_ response: HTTPDataResponse) -> HTTPError? {
        if let data = response.body, !data.isEmpty {
            if let errors = try? decoder.decode(_ErrorResponse.self, from: data).errors, !errors.isEmpty {
                return HTTPError.backend(response, error: ErrorResponse(
                    body: String(data: data, encoding: .utf8) ?? "unknown",
                    errorCodes: errors.compactMap(\.code),
                    requestId: response.headers.getBackendRequestId()
                ))
            }
        }
        return HTTPResponse.statusCodeValidator(response)
    }
}
