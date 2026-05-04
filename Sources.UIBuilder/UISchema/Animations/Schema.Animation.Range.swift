//
//  Schema.Animation.Range.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation.Range: Decodable where T: Decodable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(T.self, forKey: .start)
        end = try container.decode(T.self, forKey: .end)
    }
}

