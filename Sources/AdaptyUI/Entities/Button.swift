//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button {
        package let action: ButtonAction
        package let normalState: AdaptyUI.Element
        package let selectedState: AdaptyUI.Element?
        package let selectedCondition: SelectedCondition?
    }
}

extension AdaptyUI.Button {
    package enum SelectedCondition {
        case selectedSection(id: String, index: Int)
        case selectedProduct(id: String, groupId: String)
    }
}

#if DEBUG
    package extension AdaptyUI.Button {
        static func create(
            action: AdaptyUI.ButtonAction,
            normalState: AdaptyUI.Element,
            selectedState: AdaptyUI.Element? = nil,
            selectedCondition: SelectedCondition? = nil
        ) -> Self {
            .init(
                action: action,
                normalState: normalState,
                selectedState: selectedState,
                selectedCondition: selectedCondition
            )
        }
    }
#endif

extension AdaptyUI.Button.SelectedCondition: Decodable {
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
