//
//  HTTPSession.Logger.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private let log = Log.network

extension HTTPSession {
    enum Logger {
        static func request(_ request: URLRequest, endpoint: HTTPEndpoint, session: URLSessionConfiguration? = nil, stamp: String) {
            let url = request.url
            let query = if let data = url?.query { " ?\(data)" } else { "" }
            let path: String = if endpoint.path.isEmpty, let url { url.relativeString } else { endpoint.path }

            log.verbose("""
            \(endpoint.method) --> \(path)\(query) [\(stamp)]
            ----------REQUEST START----------
            \(request.curlCommand(session: session, verbose: true))
            ----------REQUEST END------------
            """)
        }

        static func encoding(endpoint: HTTPEndpoint, error: HTTPError) {
            log.error("ENCODING ERROR !-- \(endpoint) -- \(error)")
        }

        static func response(_ response: URLResponse?, data: Data?, endpoint: HTTPEndpoint, error: HTTPError?, request: URLRequest, stamp: String) {
            let metrics = "" // logMetrics(nil)
            let path: String =
                if endpoint.path.isEmpty, let url = response?.url ?? request.url { url.relativeString } else { endpoint.path }

            func responseAsString(_ response: URLResponse?) -> String {
                guard let response = response as? HTTPURLResponse else {
                    return "HTTP ???"
                }
                let headers = response.allHeaderFields.map { "\($0): \($1)" }.joined(separator: "\" -H \"")
                return "HTTP \(response.statusCode)" + (headers.isEmpty ? "" : (" -H \"" + headers + "\""))
            }

            func dataAsString(_ data: Data?) -> String {
                guard let data, let str = String(data: data, encoding: .utf8), !str.isEmpty else {
                    return ""
                }
                return " -d '\(str)'"
            }

            guard let error else {
                log.verbose("""
                RESPONSE <-- \(endpoint.method) \(path) [\(stamp)] \(metrics)
                ----------RESPONSE START----------
                \(responseAsString(response))
                \(dataAsString(data))
                ----------RESPONSE END------------
                """)
                return
            }

            if case let .network(_, _, error: error) = error,
               (error as NSError).isNetworkConnectionError {
                log.verbose("NO CONNECTION <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)")
            } else if error.isCancelled {
                log.verbose("CANCELED <-- \(endpoint.method) \(path) [\(stamp)] \(metrics)")
            } else {
                if Log.isLevel(.verbose), error.statusCode != nil {
                    log.error("""
                    ERROR <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)
                    ----------RESPONSE START----------
                    \(responseAsString(response))
                    \(dataAsString(data))
                    ----------RESPONSE END------------
                    """)
                } else {
                    log.error("ERROR <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)")
                }
            }
        }

        fileprivate static func logMetrics(_ metrics: URLSessionTaskMetrics?) -> String {
            guard let metrics else { return "" }
            guard
                let m = metrics.transactionMetrics.last,
                let fetchStartDate = m.fetchStartDate,
                let requestEndDate = m.requestEndDate,
                let responseStartDate = m.responseStartDate,
                let responseEndDate = m.responseEndDate
            else { return String(format: " - %.3fs", metrics.taskInterval.duration) }
            return String(format: " - %.3fs \t\t\t( ", metrics.taskInterval.duration)
                + logTimeInterval(requestEndDate.timeIntervalSince(fetchStartDate))
                + "." + logTimeInterval(responseStartDate.timeIntervalSince(requestEndDate))
                + "." + logTimeInterval(responseEndDate.timeIntervalSince(responseStartDate))
                + " )"

            func logTimeInterval(_ t: TimeInterval) -> String {
                let r = String(Int(t * 1000))
                return r.count < 2 ? "  " : r
            }
        }
    }
}
