//
//  URLRequest.KinesisSigning.swift
//  Adapty
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import Foundation

extension URLRequest {
    fileprivate enum KinesisSigning {
        static let hmacShaTypeString = "AWS4-HMAC-SHA256"

        static let iso8601DateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyyMMdd'T'HHmmssXXXXX"
            return formatter
        }()
    }

    func tryKinesisSigning(endpoint: HTTPEndpoint, credentials: KinesisCredentials) -> Result<URLRequest, HTTPError> {
        tryKinesisSigning(endpoint: endpoint,
                          secretSigningKey: credentials.secretSigningKey,
                          accessKeyId: credentials.accessKeyId,
                          sessionToken: credentials.sessionToken)
    }

    func tryKinesisSigning(endpoint: HTTPEndpoint, secretSigningKey: String, accessKeyId: String, sessionToken: String) -> Result<URLRequest, HTTPError> {
        var request = self
        let fullDateString = KinesisSigning.iso8601DateFormatter.string(from: Date())
        let shortDateString = String(fullDateString[..<fullDateString.index(fullDateString.startIndex, offsetBy: 8)])

        let body: String
        if let httpBody = request.httpBody, let stringBody = String(data: httpBody, encoding: .utf8) {
            body = stringBody
        } else {
            body = ""
        }

        guard let url = request.url else {
            return .failure(HTTPError.perform(endpoint, error: KinesisError.requestWithoutURL()))
        }

        guard let method = request.httpMethod else {
            return .failure(HTTPError.perform(endpoint, error: KinesisError.requestWithoutHTTPMethod()))
        }

        guard let host = url.host else {
            return .failure(HTTPError.perform(endpoint, error: KinesisError.urlWithoutHost()))
        }

        request.setValue(sessionToken, forHTTPHeaderField: "X-Amz-Security-Token")
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue(fullDateString, forHTTPHeaderField: "X-Amz-Date")
        request.setValue(Kinesis.Configuration.amzTargetHeader, forHTTPHeaderField: "X-Amz-Target")

        // ************* TASK 1: CREATE A CANONICAL REQUEST *************

        let headers = request.allHTTPHeaderFields ?? [:]

        let signedHeaders = headers.map { $0.key.lowercased() }.sorted().joined(separator: ";")
        let canonicalPath = url.path.isEmpty ? "/" : url.path
        let canonicalQuery = url.query ?? ""
        let canonicalHeaders = headers.map { $0.key.lowercased() + ":" + $0.value }.sorted().joined(separator: "\n")
        let canonicalRequest = [method, canonicalPath, canonicalQuery, canonicalHeaders, "", signedHeaders, body.sha256()].joined(separator: "\n")

        // ************* TASK 2: CREATE THE STRING TO SIGN *************

        let credential = [shortDateString, Kinesis.Configuration.region, Kinesis.Configuration.serviceType, Kinesis.Configuration.awsRequest].joined(separator: "/")

        let stringToSign = [KinesisSigning.hmacShaTypeString, fullDateString, credential, canonicalRequest.sha256()].joined(separator: "\n")

        // ************* TASK 3: CALCULATE THE SIGNATURE *************
        let signature = HMAC(secret: "AWS4" + secretSigningKey, algorithm: .sha256)
            .authenticatedChain(with: shortDateString)
            .authenticatedChain(with: Kinesis.Configuration.region)
            .authenticatedChain(with: Kinesis.Configuration.serviceType)
            .authenticatedChain(with: Kinesis.Configuration.awsRequest)
            .authenticate(with: stringToSign)
            .toHexString()

        // ************* TASK 4: ADD SIGNING INFORMATION TO THE REQUEST *************

        let authorization = KinesisSigning.hmacShaTypeString + " Credential=" + accessKeyId + "/" + credential + ", SignedHeaders=" + signedHeaders + ", Signature=" + signature

        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        return .success(request)
    }
}
