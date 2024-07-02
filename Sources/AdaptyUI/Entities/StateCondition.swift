//
//  StateCondition.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package enum StateCondition: Sendable {
        case selectedSection(id: String, index: Int)
        case selectedProduct(id: String, groupId: String)
    }
}

extension AdaptyUI.StateCondition: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .selectedSection(id, index):
            hasher.combine(id)
            hasher.combine(index)
        case let .selectedProduct(id, groupId):
            hasher.combine(id)
            hasher.combine(groupId)
        }
    }
}

extension AdaptyUI.StateCondition: Decodable {
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
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .selectedSection:
            self = try .selectedSection(
                id: container.decode(String.self, forKey: .sectionId),
                index: container.decode(Int.self, forKey: .index)
            )
        case .selectedProduct:
            self = try .selectedProduct(
                id: container.decode(String.self, forKey: .productId),
                groupId: container.decodeIfPresent(String.self, forKey: .groupId) ?? AdaptyUI.ViewConfiguration.StringId.Product.defaultProductGroupId
            )
        }
    }
}
