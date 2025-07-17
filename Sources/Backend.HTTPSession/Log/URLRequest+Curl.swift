//
//  URLRequest+Curl.swift
//  SwiftyCURL
//
//  Created by Zakk Hoyt on 4/22/18.
//  Copyright © 2018 Zakk Hoyt. All rights reserved.
//

import Foundation

private enum CurlParameters {
    static let url = " \"%@\""
    static let httpMethod = " -X %@"
    static let verbosity = " -v"
    static let header = " -H \"%@:%@\""
    static let cookies = " -b \"%@\""
    static let credential = " -u %@:%@"
    static let data = " -d '%@'"
}

extension URLRequest {
    func curlCommand(session: URLSessionConfiguration? = nil, verbose: Bool = false) -> String {
        guard let url,
              let host = url.host,
              let httpMethod
        else { return "$ curl command could not be created" }

        let verboseString = verbose ? CurlParameters.verbosity : ""

        var credentialString = ""
        if let credentialStorage = session?.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: url.port ?? 0,
                protocol: url.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )

            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password else { continue }
                    credentialString += String(format: CurlParameters.credential, user, password)
                }
            }
        }

        var cookieString = ""
        if let session, session.httpShouldSetCookies {
            if
                let cookieStorage = session.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty {
                let allCookies = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: ";")

                cookieString = String(format: CurlParameters.cookies, allCookies)
            }
        }

        var headersCollection = allHTTPHeaderFields ?? [:]
        if let headers = session?.httpAdditionalHeaders as? [String: String] {
            for header in headers {
                if headersCollection.keys.contains(header.key) { continue }
                headersCollection[header.key] = header.value
            }
        }

        var headerString = ""
        for (key, value) in headersCollection where key != "Cookie" {
            headerString += String(format: CurlParameters.header, key, value)
        }

        var dataString = ""
        if let httpBody {
            if let d = String(data: httpBody, encoding: String.Encoding.utf8) {
                dataString = String(format: CurlParameters.data, d)
            }
        }

        return "$ curl"
            + verboseString
            + String(format: CurlParameters.httpMethod, httpMethod)
            + headerString
            + dataString
            + cookieString
            + credentialString
            + String(format: CurlParameters.url, url.absoluteString)
    }
}
