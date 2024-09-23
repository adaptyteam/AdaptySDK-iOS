//
//  AdaptyError+Encodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation

extension AdaptyError: Encodable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "adapty_code"
        case debugDescription = "message"
        case description = "detail"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encode(debugDescription, forKey: .debugDescription)
        try container.encode(description, forKey: .description)
    }
}
