//
//  AdaptyStorefront.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation

public struct AdaptyStorefront: Sendable, Identifiable, Hashable {
    public let id: String
    public let countryCode: String
}

extension AdaptyStorefront: CustomStringConvertible {
    public var description: String {
        "\(id) \(countryCode)"
    }
}

extension AdaptyStorefront: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case countryCode = "country_code"
    }
}
