//
//  Kinesis.swift
//  Adapty
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import Foundation

final class Kinesis {
    struct Configuration: HTTPCodableConfiguration {
        static let publicEnvironmentBaseUrl = URL(string: "https://kinesis.us-east-1.amazonaws.com")!
        static let publicStreamName = "adapty-data-pipeline-prod"
        static let devStreamName = "adapty-data-pipeline-dev"
        static let region = "us-east-1"
        static let amzTargetHeader = "Kinesis_20131202.PutRecords"
        static let serviceType = "kinesis"
        static let awsRequest = "aws4_request"

        let baseURL: URL
        let sessionConfiguration: URLSessionConfiguration
        let defaultEncodedContentType = "application/x-amz-json-1.1"

        func configure(decoder: JSONDecoder) {
            decoder.dateDecodingStrategy = .millisecondsSince1970
            decoder.dataDecodingStrategy = .base64
        }

        func configure(encoder: JSONEncoder) {
            encoder.dateEncodingStrategy = .millisecondsSince1970
            encoder.dataEncodingStrategy = .base64
        }
    }

    let configuration: Configuration
    var credentials: KinesisCredentials?

    init(baseURL url: URL = Configuration.publicEnvironmentBaseUrl, credentials: KinesisCredentials?) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.configuration = Configuration(baseURL: url, sessionConfiguration: configuration)
        self.credentials = credentials
    }

    func createHTTPSession(responseQueue: DispatchQueue,
                           errorHandler: ((HTTPError) -> Void)? = nil) -> HTTPSession {
        HTTPSession(configuration: configuration,
                    responseQueue: responseQueue,
                    requestSign: { [weak self] request, endpoint in
                        guard let credentials = self?.credentials else {
                            return .failure(HTTPError.perform(endpoint, error: KinesisError.missingСredentials()))
                        }
                        return request.tryKinesisSigning(endpoint: endpoint, credentials: credentials)
                    },
                    errorHandler: errorHandler)
    }
}
