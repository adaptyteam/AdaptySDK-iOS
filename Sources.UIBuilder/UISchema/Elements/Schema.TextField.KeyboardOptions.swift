//
//  Schema.TextField.KeyboardOptions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension Schema.TextField.KeyboardOptions {
    @inlinable
    var isEmpty: Bool {
        keyboardType == nil
            && contentType == nil
            && autocapitalizationType == nil
            && submitButton == nil
    }

    @inlinable
    var nonEmptyOrNil: Self? {
        isEmpty ? nil : self
    }
}

extension Schema.TextField.KeyboardOptions: Decodable {
    enum CodingKeys: String, CodingKey {
        case keyboardType = "keyboard"
        case contentType = "content_type"
        case autocapitalizationType = "auto_capitalization"
        case submitButton = "submit_button"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            keyboardType: container.decodeIfPresent(String.self, forKey: .keyboardType),
            contentType: container.decodeIfPresent(String.self, forKey: .contentType),
            autocapitalizationType: container.decodeIfPresent(String.self, forKey: .autocapitalizationType),
            submitButton: container.decodeIfPresent(String.self, forKey: .submitButton)
        )
    }
}

