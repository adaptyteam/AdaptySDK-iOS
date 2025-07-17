//
//  HTTPSession.Log.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

private let log = Log.http

extension Log {
    static func encodingError(_ error: Error, endpoint: HTTPEndpoint, stamp: String) {
        log.error("ENCODING ERROR --> \(endpoint) [\(stamp)]: \(error)")
    }

    static func request(_ request: URLRequest, endpoint: HTTPEndpoint, session: URLSessionConfiguration? = nil, stamp: String) {
        guard Log.isLevel(.verbose) else { return }

        let url = request.url
        let query = if let query = url?.query { " ?\(query)" } else { "" }

        log.verbose("""
        \(endpoint.method) --> \(endpoint.pathAsLogString(url))\(query) [\(stamp)]
        ----------REQUEST START----------
        \(request.curlCommand(session: session, verbose: true))
        ----------REQUEST END------------
        """)
    }

    static func responseError(_ error: HTTPError, request: URLRequest, stamp: String, response: HTTPDataResponse?) {
        if case let .network(_, _, _, error: originalError) = error,
           originalError.isNetworkConnectionError {
            log.verbose("NO CONNECTION <-- \(error.endpoint.method) \(error.endpoint.pathAsLogString(request.url)) [\(stamp)] -- \(error)\(error.metrics?.debugDescription ?? "")")
        } else if error.isCancelled {
            log.verbose("CANCELED <-- \(error.endpoint.method) \(error.endpoint.pathAsLogString(request.url)) [\(stamp)]\(error.metrics?.debugDescription ?? "")")
        } else {
            log.error("ERROR <-- \(error.endpoint.method) \(error.endpoint.pathAsLogString(request.url)) [\(stamp)] -- \(error)\(error.metrics?.debugDescription ?? "")\((Log.isLevel(.verbose) ? response : nil)?.asLogString ?? "")")
        }
    }

    static func response(_ response: HTTPDataResponse, request: URLRequest, stamp: String) {
        guard Log.isLevel(.verbose) else { return }

        log.verbose("\(response.statusCode) <-- \(response.endpoint.method) \(response.endpoint.pathAsLogString(request.url)) [\(stamp)]\(response.metrics?.debugDescription ?? "")\(response.asLogString)")
    }
}

private extension HTTPEndpoint {
    func pathAsLogString(_ url: URL?) -> String {
        if path.isEmpty, let url { url.relativeString } else { path }
    }
}

private extension HTTPDataResponse {
    var asLogString: String {
        let headers = self.headers.map { "\($0): \($1)" }.joined(separator: "\" -H \"")

        return """

        ----------RESPONSE START----------
        HTTP \(statusCode)\(headers.isEmpty ? "" : " -H \"\(headers)\"")
        \(body.asLogString)
        ----------RESPONSE END------------
        """
    }
}

private extension Data? {
    var asLogString: String {
        guard let data = self, let str = String(data: data, encoding: .utf8), !str.isEmpty else { return "" }
        return " -d '\(str)'"
    }
}
