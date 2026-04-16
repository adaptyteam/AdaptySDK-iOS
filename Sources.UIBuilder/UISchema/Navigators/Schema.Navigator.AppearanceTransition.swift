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

extension Schema.Navigator.AppearanceTransition: Decodable {
    enum CodingKeys: String, CodingKey {
        case background
        case content
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            background: container.decodeIfPresent(Schema.Animation.Background.self, forKey: .background),
            content: container.decodeIfPresent([Schema.Animation].self, forKey: .content)
        )
    }
}
