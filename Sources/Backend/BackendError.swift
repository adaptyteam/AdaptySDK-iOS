//
//  BackendError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2022.
//

import Foundation

struct BackendError: Error, Hashable, Codable {
    let body: String
    let errorCodes: [String]
    let requestId: String?
}

enum ResponseDecodingError: Error, Hashable, Codable {
    case profileWasChanged
    case crossPlacementABTestDisabled
    case notFoundVariationId
}

extension BackendError: CustomStringConvertible {
    public var description: String {
        (requestId.map { "requestId: \($0), " } ?? "") + "body: \(body)"
    }
}

extension Backend {
    static func responseDecodingError(_ decodingError: Set<ResponseDecodingError>, _ error: HTTPError) -> Bool {
        switch error {
        case let .decoding(_, _, _, _, _, value):
            if let value = value as? ResponseDecodingError {
                decodingError.contains(value)
            } else {
                false
            }
        default:
            false
        }
    }

    static func wrongProfileSegmentId(_ error: HTTPError) -> Bool {
        backendErrorCodes(error).contains("INCORRECT_SEGMENT_HASH_ERROR")
    }

    static func wrongPlacementContentType(_ error: HTTPError) -> Bool {
        backendErrorCodes(error).contains("UNSUPPORTED_PLACEMENT_TYPE_ERROR")
    }

    static func backendErrorCodes(_ error: HTTPError) -> [String] {
        switch error {
        case let .backend(_, _, _, _, _, value):
            (value as? BackendError)?.errorCodes ?? []
        default: []
        }
    }

    static func canUseFallbackServer(_ error: HTTPError) -> Bool {
        switch error {
        case .perform:
            false
        case let .network(_, _, _, value):
            (value as NSError).isTimedOutError
        case let .decoding(_, _, statusCode, _, _, _),
             let .backend(_, _, statusCode, _, _, _):
            switch statusCode {
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
        case let .network(_, _, _, error: error):
            (error as NSError).isNetworkConnectionError
        case let .decoding(_, _, statusCode, _, _, _),
             let .backend(_, _, statusCode, _, _, _):
            switch statusCode {
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
