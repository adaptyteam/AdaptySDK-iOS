//
//  AdaptyUserId.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.07.2025.
//

package struct AdaptyUserId: Sendable, Hashable {
    package let profileId: String
    package let customerId: String?
}

extension AdaptyUserId {
    var isAnonymous: Bool { customerId == nil }

    func isEqualProfileId(_ other: AdaptyUserId) -> Bool {
        profileId == other.profileId
    }

    func isNotEqualProfileId(_ other: AdaptyUserId) -> Bool {
        !isEqualProfileId(other)
    }
}

extension AdaptyUserId: CustomStringConvertible {
    package var description: String {
        "(profileId: \(profileId), customerUserId: \(customerId ?? "nil")"
    }
}

extension AdaptyUserId: Codable {
    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case customerId = "customer_Id"
    }
}
