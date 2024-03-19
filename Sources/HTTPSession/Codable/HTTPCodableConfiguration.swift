//
//  HTTPCodableConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

protocol HTTPCodableConfiguration: HTTPConfiguration {
    func configure(decoder: JSONDecoder)
    func configure(encoder: JSONEncoder)
    var defaultEncodedContentType: String { get }
}

extension JSONDecoder {
    func configure(with config: HTTPCodableConfiguration) {
        config.configure(decoder: self)
    }
}

extension JSONEncoder {
    func configure(with config: HTTPCodableConfiguration) {
        config.configure(encoder: self)
    }
}

extension HTTPCodableConfiguration {
    var defaultEncodedContentType: String { "application/json" }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        configure(decoder: decoder)
        return decoder
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        configure(encoder: encoder)
        return encoder
    }

    func configure(decoder: JSONDecoder) {
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.millisecondsSince1970
    }

    func configure(encoder: JSONEncoder) {
        encoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.millisecondsSince1970
    }
}
