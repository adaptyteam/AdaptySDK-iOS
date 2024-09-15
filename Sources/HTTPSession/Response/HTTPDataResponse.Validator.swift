//
//  HTTPDataResponse.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

extension HTTPDataResponse {
    typealias Validator = @Sendable (HTTPDataResponse) -> Error?
    static let defaultValidator: Validator = statusCodeValidator

    @Sendable
    static func statusCodeValidator(_ response: HTTPDataResponse) -> Error? {
        200 ... 299 ~= response.statusCode ? nil : URLError(.badServerResponse)
    }
}
