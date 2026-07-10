//
//  Schema.Pager.EdgePageOverrides.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 10.07.2026.
//

import Foundation

extension Schema.Pager {
    typealias EdgePageOverrides = VC.Pager.EdgePageOverrides
}

extension Schema.Pager.EdgePageOverrides {
    var isEmpty: Bool {
        leadingPadding == nil && trailingPadding == nil
    }
}

extension Schema.Pager.EdgePageOverrides: Decodable {
    enum CodingKeys: String, CodingKey {
        case leadingPadding = "leading_padding"
        case trailingPadding = "trailing_padding"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            leadingPadding: container.decodeIfPresent(Schema.Unit.self, forKey: .leadingPadding),
            trailingPadding: container.decodeIfPresent(Schema.Unit.self, forKey: .trailingPadding)
        )
    }
}
