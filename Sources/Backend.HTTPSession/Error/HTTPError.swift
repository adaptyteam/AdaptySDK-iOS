//
//  HTTPError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import Foundation

enum HTTPError: Error {
    typealias Source = AdaptyError.Source

    case perform(HTTPEndpoint, Source, error: Error)
    case network(HTTPEndpoint, Source, metrics: HTTPMetrics?, error: Error)
    case decoding(HTTPEndpoint, Source, statusCode: Int, headers: HTTPHeaders, metrics: HTTPMetrics?, error: Error)
    case backend(HTTPEndpoint, Source, statusCode: Int, headers: HTTPHeaders, metrics: HTTPMetrics?, error: Error?)
}

extension HTTPError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .network(endpoint, source, _, error: error):
            "HTTPError.network(\(endpoint), \(source), \(error))"
        case let .perform(endpoint, source, error: error):
            "HTTPError.perform(\(endpoint), \(source), \(error))"
        case let .decoding(endpoint, source, statusCode: statusCode, headers: _, _, error: error):
            "HTTPError.decoding(\(endpoint), \(source), statusCode: \(statusCode), \(error))"
        case let .backend(endpoint, source, statusCode: statusCode, headers: _, _, error: error):
            "HTTPError.backend(\(endpoint), \(source), statusCode: \(statusCode)"
                + (error.map { ", \($0)" } ?? "")
                + ")"
        }
    }
}

extension HTTPError {
    var source: AdaptyError.Source {
        switch self {
        case let .network(_, src, _, _),
             let .perform(_, src, _),
             let .decoding(_, src, _, _, _, _),
             let .backend(_, src, _, _, _, _): src
        }
    }

    var endpoint: HTTPEndpoint {
        switch self {
        case let .network(endpoint, _, _, _),
             let .perform(endpoint, _, _),
             let .decoding(endpoint, _, _, _, _, _),
             let .backend(endpoint, _, _, _, _, _): endpoint
        }
    }

    var statusCode: Int? {
        switch self {
        case let .decoding(_, _, code, _, _, _),
             let .backend(_, _, code, _, _, _): code
        default: nil
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case let .decoding(_, _, _, headers, _, _),
             let .backend(_, _, _, headers, _, _): headers
        default: nil
        }
    }

    public var metrics: HTTPMetrics? {
        switch self {
        case let .network(_, _, metrics, _),
             let .decoding(_, _, _, _, metrics, _),
             let .backend(_, _, _, _, metrics, _):
            metrics
        default:
            nil
        }
    }

    var originalError: Error? {
        switch self {
        case let .perform(_, _, err),
             let .network(_, _, _, err),
             let .decoding(_, _, _, _, _, err): err
        case let .backend(_, _, _, _, _, err): err
        }
    }

    var isCancelled: Bool {
        switch self {
        case let .network(_, _, _, err):
            err.isCancellationError
        default:
            false
        }
    }
}

extension Error {
    fileprivate var isCancellationError: Bool {
        if self is CancellationError { return true }
        if (self as? URLError)?.code == .cancelled { return true }
        return (self as NSError).isCancellationError
    }

    var isNetworkConnectionError: Bool {
        (self as NSError).isNetworkConnectionError
    }

    fileprivate var isTimedOutError: Bool {
        (self as NSError).isTimedOutError
    }
}

extension NSError {
    private var nsURLErrorCode: Int? {
        guard domain == NSURLErrorDomain else { return nil }
        return code
    }

    private static let networkConnectionErrorsCodes = [
        NSURLErrorNotConnectedToInternet,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorDNSLookupFailed,
        NSURLErrorResourceUnavailable,
        NSURLErrorCannotFindHost,
        NSURLErrorCannotConnectToHost,
    ]

    private static let timedOutErrorsCodes = [
        NSURLErrorTimedOut,
    ]

    var isNetworkConnectionError: Bool {
        guard let code = nsURLErrorCode else { return false }
        return NSError.networkConnectionErrorsCodes.contains(code)
    }

    var isCancellationError: Bool {
        nsURLErrorCode == NSURLErrorCancelled
    }

    var isTimedOutError: Bool {
        guard let code = nsURLErrorCode else { return false }
        return NSError.timedOutErrorsCodes.contains(code)
    }
}

extension HTTPError {
    static func cancelled(
        _ endpoint: HTTPEndpoint,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .network(
            endpoint,
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            metrics: nil,
            error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)
        )
    }

    static func perform(
        _ endpoint: HTTPEndpoint,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .perform(
            endpoint,
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func network(
        _ endpoint: HTTPEndpoint,
        metrics: HTTPMetrics?,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .network(
            endpoint,
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            metrics: metrics,
            error: error
        )
    }

    static func decoding(
        _ response: HTTPDataResponse,
        error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .decoding(
            response.endpoint,
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            statusCode: response.statusCode,
            headers: response.headers,
            metrics: response.metrics,
            error: error
        )
    }

    static func backend(
        _ response: HTTPDataResponse,
        error: Error? = nil,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .backend(
            response.endpoint,
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            statusCode: response.statusCode,
            headers: response.headers,
            metrics: response.metrics,
            error: error
        )
    }
}
