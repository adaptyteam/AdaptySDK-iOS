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
        struct Error: Decodable {}
    }

    func validator(_ response: HTTPDataResponse) -> HTTPError? {
        if let data = response.body, !data.isEmpty {
            if let body = try? decoder.decode(_ErrorResponse.self, from: data),
               !(body.errors?.isEmpty ?? true),
               let string = String(data: data, encoding: .utf8) {
                return HTTPError.backend(response, error: ErrorResponse(
                    body: string,
                    requestId: response.headers.getBackendRequestId()
                ))
            }
        }
        return HTTPResponse.statusCodeValidator(response)
    }
}
