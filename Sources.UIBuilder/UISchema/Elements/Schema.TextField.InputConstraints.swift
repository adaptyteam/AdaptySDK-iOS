//
//  Schema.TextField.InputConstraints.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension Schema.TextField.InputConstraints {
    @inlinable
    var isEmpty: Bool {
        regex == nil && maxLength == nil
    }

    @inlinable
    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }
}

extension Schema.TextField.InputConstraints: Codable {
    enum CodingKeys: String, CodingKey {
        case regex
        case maxLength = "max_length"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            regex: container.decodeIfPresent(String.self, forKey: .regex),
            maxLength: container.decodeIfPresent(Int.self, forKey: .maxLength)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(regex, forKey: .regex)
        try container.encodeIfPresent(maxLength, forKey: .maxLength)
    }
}
