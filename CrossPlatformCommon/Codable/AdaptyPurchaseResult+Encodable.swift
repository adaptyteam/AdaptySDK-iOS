//
//  AdaptyPurchaseResult+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptyPurchaseResult: Encodable {
    private enum CodingKeys: String, CodingKey {
        case resultType = "type"
        case profile
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending:
            try container.encode("pending", forKey: .resultType)
        case .userCancelled:
            try container.encode("user_cancelled", forKey: .resultType)
        case .success(let profile, _):
            try container.encode("success", forKey: .resultType)
            try container.encode(profile, forKey: .profile)
        }
    }
}
