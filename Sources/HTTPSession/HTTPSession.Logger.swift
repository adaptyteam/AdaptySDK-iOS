//
//  HTTPSession.Logger.swift
//  Adapty
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension HTTPSession {
    struct Logger: Sendable {
        static func request(_ request: URLRequest, endpoint: HTTPEndpoint) {
            let url = request.url
            let query: String
            if let data = url?.query {
                query = " ?\(data)"
            } else {
                query = ""
            }

            let body: String
            if let data = request.httpBody, !data.isEmpty {
                let length = data.count
                body = length < 200 ? String(decoding: data, as: UTF8.self) : "bytes[\(length)]"
            } else {
                body = ""
            }
            Log.verbose("#API# \(endpoint.method) --> \(endpoint.path)\(query) \(body)")
        }

        static func encoding(endpoint: HTTPEndpoint, error: HTTPError) {
            Log.error("#API# ENCODING ERROR !-- \(endpoint) -- \(error)")
        }

        static func response(_ response: URLResponse?, endpoint: HTTPEndpoint, error: HTTPError?, session: URLSessionConfiguration? = nil, request: URLRequest?, forceLogCurl: Bool = false) {
            let metrics = "" // logMetrics(nil)
            guard let error = error else {
                if forceLogCurl, let request = request {
                    Log.debug("#API# " + request.curlCommand(session: session, verbose: true))
                }
                Log.verbose("#API# RESPONSE <-- \(endpoint) \(metrics)")
                return
            }

            if case let .network(_, _, error: error) = error,
               (error as NSError).isNetworkConnectionError {
                Log.verbose("#API# NO CONNECTION <-- \(endpoint) \(metrics)")
            } else if error.isCancelled {
                Log.verbose("#API# CANCELED <-- \(endpoint) \(metrics)")
            } else {
                if let request = request {
                    Log.debug("#API# " + request.curlCommand(session: session, verbose: true))
                }
                Log.error("#API# ERROR <-- \(endpoint) -- \(error) \(metrics)")
            }
        }

        @available(iOS 10.0, *)
        fileprivate static func logMetrics(_ metrics: URLSessionTaskMetrics?) -> String {
            guard let metrics = metrics else { return "" }
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
