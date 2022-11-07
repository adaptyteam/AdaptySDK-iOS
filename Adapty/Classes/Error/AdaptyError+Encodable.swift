//
//  AdaptyError+Encodable.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation

extension AdaptyError: Encodable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "code"
        case debugDescription = "message"
        case source
        case originalError
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encodeIfPresent(debugDescription, forKey: .debugDescription)
        try container.encode(wrapped.source.description, forKey: .source)

        if let originalError = originalError {
            try container.encode("\(originalError)", forKey: .originalError)
        }
    }
}
