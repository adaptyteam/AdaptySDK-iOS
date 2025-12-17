//
//  Schema.StateCondition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema {
    typealias StateCondition = VC.StateCondition
}

extension Schema.StateCondition: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case productId = "product_id"
        case groupId = "group_id"
        case sectionId = "section_id"
        case index
    }

    enum Types: String {
        case selectedSection = "selected_section"
        case selectedProduct = "selected_product"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try Types(rawValue: container.decode(String.self, forKey: .type)) {
        case nil:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .selectedSection:
            self = try .selectedSection(
                id: container.decode(String.self, forKey: .sectionId),
                index: container.decode(Int32.self, forKey: .index)
            )
        case .selectedProduct:
            self = try .selectedProduct(
                id: container.decode(String.self, forKey: .productId),
                groupId: container.decodeIfPresent(String.self, forKey: .groupId) ?? "group_A"
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .selectedSection(sectionId, index):
            try container.encode(Types.selectedSection.rawValue, forKey: .type)
            try container.encode(sectionId, forKey: .sectionId)
            try container.encode(index, forKey: .index)
        case let .selectedProduct(productId, groupId):
            try container.encode(Types.selectedProduct.rawValue, forKey: .type)
            try container.encode(productId, forKey: .productId)
            if groupId != "group_A" {
                try container.encode(groupId, forKey: .groupId)
            }
        }
    }
}
