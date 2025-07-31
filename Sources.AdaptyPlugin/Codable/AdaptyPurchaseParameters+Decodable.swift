//
//  AdaptyPurchaseParameters+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 24.07.2025.
//

import Adapty
import Foundation

extension AdaptyPurchaseParameters: Decodable {
    enum CodingKeys: String, CodingKey {
        case appAccountToken = "app_account_token"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            appAccountToken: container.decodeIfPresent(AdaptyPurchaseParameters.AppAccountTokenValue.self, forKey: .appAccountToken) ?? .default
        )
    }
}

extension AdaptyPurchaseParameters.AppAccountTokenValue: Decodable {
    enum CodingKeys: String, CodingKey {
        case value
    }

    enum Values: String, Decodable {
        case none
        case customerUserId = "customer_user_id"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Values.self, forKey: .value) {
            case .none:
                self = .none
            case .customerUserId:
                self = .customerUserId
        }
    }
}
