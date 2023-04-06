//
//  BackendError.swift
//  Adapty
//
//  Created by Aleksei Valiano on 06.10.2022.
//

import Foundation

struct ErrorResponse: Codable, Error, Equatable {
    let body: String
    let requestId: String?
}

extension ErrorResponse: CustomStringConvertible {
    public var description: String {
        (requestId == nil ? "" : "requestId: \(requestId!), ") + "body: \(body)"
    }
}

extension Backend {
    // TODO: Retry Codes
    static func canRetryRequest(error: HTTPError) -> Bool {
        switch error {
        case .perform:
            return false
        case let .network(_, _, error: error):
            return (error as NSError).isNetworkConnectionError
        case let .decoding(_, _, statusCode: code, _, _),
             let .backend(_, _, statusCode: code, _, _):
            switch code {
            case 429, 499, 500 ... 599:
                return true
            default:
                return false
            }
        }
    }

    static func toAdaptyErrorCode(statusCode: Int) -> AdaptyError.ErrorCode? {
        switch statusCode {
        case 200 ... 299: return nil
        case 401, 403: return .notActivated
        case 429, 499, 500 ... 599: return .serverError
        case 400 ... 499: return .badRequest
        default: return .networkFailed
        }
    }
}
