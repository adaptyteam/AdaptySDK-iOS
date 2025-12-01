//
//  Schema.Pager.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager {
    typealias Length = VC.Pager.Length
}

extension Schema.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(VC.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let value = try container.decodeIfPresent(Double.self, forKey: .parent)
            else { throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found parent")
            ) }
            self = .parent(value)
        }
    }
}
