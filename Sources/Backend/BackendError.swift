//
//  BackendError.swift
//  AdaptySDK
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
        (requestId.map { "requestId: \($0), " } ?? "") + "body: \(body)"
    }
}

extension Backend {
    static func canUseFallbackServer(_ error: HTTPError) -> Bool {
        switch error {
        case .perform:
            false
        case let .network(_, _, error: error):
            (error as NSError).isTimedOutError
        case let .decoding(_, _, statusCode: code, _, _),
             let .backend(_, _, statusCode: code, _, _):
            switch code {
            case 499, 500 ... 599:
                true
            default:
                false
            }
        }
    }

    // TODO: Retry Codes
    static func canRetryRequest(_ error: HTTPError) -> Bool {
        switch error {
        case .perform:
            false
        case let .network(_, _, error: error):
            (error as NSError).isNetworkConnectionError
        case let .decoding(_, _, statusCode: code, _, _),
             let .backend(_, _, statusCode: code, _, _):
            switch code {
            case 429, 499, 500 ... 599:
                true
            default:
                false
            }
        }
    }

    static func toAdaptyErrorCode(statusCode: Int) -> AdaptyError.ErrorCode? {
        switch statusCode {
        case 200 ... 299: nil
        case 401, 403: .notActivated
        case 429, 499, 500 ... 599: .serverError
        case 400 ... 499: .badRequest
        default: .networkFailed
        }
    }
}
