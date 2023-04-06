//
//  HTTPError.swift
//  Adapty
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import Foundation

enum HTTPError: Error {
    case perform(HTTPEndpoint, AdaptyError.Source, error: Error)
    case network(HTTPEndpoint, AdaptyError.Source, error: Error)
    case decoding(HTTPEndpoint, AdaptyError.Source, statusCode: Int, headers: [AnyHashable: Any], error: Error)
    case backend(HTTPEndpoint, AdaptyError.Source, statusCode: Int, headers: [AnyHashable: Any], error: Error?)
}

extension HTTPError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .network(endpoint, source, error: error):
            return "HTTPError.network(\(endpoint), \(source), \(error))"
        case let .perform(endpoint, source, error: error):
            return "HTTPError.perform(\(endpoint), \(source), \(error))"
        case let .decoding(endpoint, source, statusCode: statusCode, headers: _, error: error):
            return "HTTPError.decoding(\(endpoint), \(source), statusCode: \(statusCode), \(error))"
        case let .backend(endpoint, source, statusCode: statusCode, headers: _, error: error):
            return "HTTPError.backend(\(endpoint), \(source), statusCode: \(statusCode)"
                + (error == nil ? "" : ", \(error!)")
                + ")"
        }
    }
}

extension HTTPError {
    var source: AdaptyError.Source {
        switch self {
        case let .network(_, src, _),
             let .perform(_, src, _),
             let .decoding(_, src, _, _, _),
             let .backend(_, src, _, _, _):
            return src
        }
    }

    var endpoint: HTTPEndpoint {
        switch self {
        case let .network(endpoint, _, _),
             let .perform(endpoint, _, _),
             let .decoding(endpoint, _, _, _, _),
             let .backend(endpoint, _, _, _, _):
            return endpoint
        }
    }

    var statusCode: Int? {
        switch self {
        case
            let .decoding(_, _, code, _, _),
            let .backend(_, _, code, _, _):
            return code
        default:
            return nil
        }
    }

    var headers: [AnyHashable: Any]? {
        switch self {
        case
            let .decoding(_, _, _, headers, _),
            let .backend(_, _, _, headers, _):
            return headers
        default:
            return nil
        }
    }

    var originalError: Error? {
        switch self {
        case let .network(_, _, err),
             let .perform(_, _, err),
             let .decoding(_, _, _, _, err):
            return err
        case let .backend(_, _, _, _, err):
            return err
        }
    }

    var isCancelled: Bool {
        switch self {
        case let .network(_, _, err):
            return (err as NSError).nsURLErrorCode == NSURLErrorCancelled
        default:
            return false
        }
    }
}

extension NSError {
    fileprivate var nsURLErrorCode: Int? {
        guard domain == NSURLErrorDomain else { return nil }
        return code
    }

    fileprivate static let networkConnectionErrorsCodes = [
        NSURLErrorNotConnectedToInternet,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorDNSLookupFailed,
        NSURLErrorResourceUnavailable,
        NSURLErrorCannotFindHost,
        NSURLErrorCannotConnectToHost,
    ]

    var isNetworkConnectionError: Bool {
        guard let code = nsURLErrorCode else { return false }
        return NSError.networkConnectionErrorsCodes.contains(code)
    }
}

extension HTTPError {
    static func cancelled(
        _ endpoint: HTTPEndpoint,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .network(endpoint,
                 AdaptyError.Source(file: file,
                                    function: function,
                                    line: line),
                 error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled))
    }

    static func network(
        _ endpoint: HTTPEndpoint,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .network(endpoint,
                 AdaptyError.Source(file: file,
                                    function: function,
                                    line: line),
                 error: error)
    }

    static func perform(
        _ endpoint: HTTPEndpoint,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .perform(endpoint,
                 AdaptyError.Source(file: file,
                                    function: function,
                                    line: line),
                 error: error)
    }

    static func decoding(
        _ response: HTTPDataResponse,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .decoding(response.endpoint,
                  AdaptyError.Source(file: file,
                                     function: function,
                                     line: line),
                  statusCode: response.statusCode,
                  headers: response.headers,
                  error: error)
    }

    static func backend(
        _ response: HTTPDataResponse,
        error: Error? = nil,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .backend(response.endpoint,
                 AdaptyError.Source(file: file,
                                    function: function,
                                    line: line),
                 statusCode: response.statusCode,
                 headers: response.headers,
                 error: error)
    }
}
