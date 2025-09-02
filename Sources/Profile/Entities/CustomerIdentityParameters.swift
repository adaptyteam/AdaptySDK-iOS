//
//  CustomerIdentityParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.09.2025.
//
import Foundation

package struct CustomerIdentityParameters {
    package let appAccountToken: UUID?
}

extension CustomerIdentityParameters: Decodable {
    private enum CodingKeys: String, CodingKey {
        case appAccountToken = "app_account_token"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appAccountToken = try container.decodeIfPresent(UUID.self, forKey: .appAccountToken)
    }
}
