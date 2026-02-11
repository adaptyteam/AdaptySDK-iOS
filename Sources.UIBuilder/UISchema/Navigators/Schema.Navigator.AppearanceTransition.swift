//
//  Schema.Navigator.AppearanceTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

extension Schema.Navigator {
    typealias AppearanceTransition = VC.Navigator.AppearanceTransition
}

extension Schema.Navigator.AppearanceTransition: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case content
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            background: container.decodeIfPresent(Schema.Animation.Background.self, forKey: .background),
            content: container.decodeIfPresent([Schema.Animation].self, forKey: .content)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let background { try container.encode(background, forKey: .background) }
        if let content, content.isNotEmpty { try container.encode(content, forKey: .content) }
    }
}
