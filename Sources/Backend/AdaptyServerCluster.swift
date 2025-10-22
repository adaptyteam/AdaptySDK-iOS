//
//  AdaptyServerCluster.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.11.2024.
//

public enum AdaptyServerCluster: Sendable {
    case `default`
    case eu
    case cn
}

extension AdaptyServerCluster: Decodable {
    public init(from decoder: Decoder) throws {
        self =
            switch try decoder.singleValueContainer().decode(String.self) {
            case "eu": .eu
            case "cn": .cn
            default: .default
            }
    }
}
