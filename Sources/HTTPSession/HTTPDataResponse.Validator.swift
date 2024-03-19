//
//  HTTPDataResponse.Validator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

extension HTTPDataResponse {
    typealias Validator = (HTTPDataResponse) -> HTTPError?
    static let defaultValidator: Validator = statusCodeValidator
    static func statusCodeValidator(_ response: HTTPDataResponse) -> HTTPError? {
        200 ... 299 ~= response.statusCode ? nil : HTTPError.backend(response)
    }
}
