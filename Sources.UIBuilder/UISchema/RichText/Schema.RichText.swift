//
//  Schema.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension Schema {
    struct RichText: Sendable, Hashable {
        let items: [RichText.Item]
    }
}

extension Schema.RichText {
    var isEmpty: Bool {
        items.isEmpty
    }
}

extension Schema.RichText: Decodable {
    init(from decoder: Decoder) throws {
        items =
            if let value = try? Item(from: decoder) {
                [value]
            } else {
                try [Item](from: decoder)
            }
    }

}
