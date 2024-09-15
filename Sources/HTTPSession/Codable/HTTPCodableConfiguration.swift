//
//  HTTPCodableConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

protocol HTTPCodableConfiguration: HTTPConfiguration {
    func configure(jsonDecoder: JSONDecoder)
    func configure(jsonEncoder: JSONEncoder)
    var defaultEncodedContentType: String { get }
}

extension HTTPCodableConfiguration {
    var defaultEncodedContentType: String { "application/json" }

    func configure(jsonDecoder: JSONDecoder) {
        jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
        jsonDecoder.dataDecodingStrategy = .base64
    }

    func configure(jsonEncoder: JSONEncoder) {
        jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
        jsonEncoder.dataEncodingStrategy = .base64
    }
}
