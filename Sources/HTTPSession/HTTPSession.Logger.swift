//
//  HTTPSession.Logger.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension HTTPSession {
    struct Logger: Sendable {
        static func request(_ request: URLRequest, endpoint: HTTPEndpoint, session: URLSessionConfiguration? = nil, stamp: String) {
            Log.verbose {
                let url = request.url

                let query: String = if let data = url?.query { " ?\(data)" } else { "" }

                let path: String = if endpoint.path.isEmpty, let url { url.relativeString } else { endpoint.path }

                return "#API# \(endpoint.method) --> \(path)\(query) [\(stamp)]\n"
                    + "----------REQUEST START----------\n"
                    + request.curlCommand(session: session, verbose: true)
                    + "\n----------REQUEST END------------"
            }
        }

        static func encoding(endpoint: HTTPEndpoint, error: HTTPError) {
            Log.error("#API# ENCODING ERROR !-- \(endpoint) -- \(error)")
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
                Log.verbose {
                    "#API# RESPONSE <-- \(endpoint.method) \(path) [\(stamp)] \(metrics)\n"
                        + "----------RESPONSE START----------\n"
                        + responseAsString(response)
                        + dataAsString(data)
                        + "\n----------RESPONSE END------------"
                }
                return
            }

            if case let .network(_, _, error: error) = error,
               (error as NSError).isNetworkConnectionError {
                Log.verbose("#API# NO CONNECTION <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)")
            } else if error.isCancelled {
                Log.verbose("#API# CANCELED <-- \(endpoint.method) \(path) [\(stamp)] \(metrics)")
            } else {
                Log.error {
                    if AdaptyLogger.isLogLevel(.verbose), error.statusCode != nil {
                        "#API# ERROR <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)\n"
                            + "----------RESPONSE START----------\n"
                            + responseAsString(response)
                            + dataAsString(data)
                            + "\n----------RESPONSE END------------"

                    } else {
                        "#API# ERROR <-- \(endpoint.method) \(path) [\(stamp)] -- \(error) \(metrics)"
                    }
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
