//
//  Schema.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation {
    typealias Range = VC.Animation.Range
}

extension Schema.Localizer {
    func animationFillingValue(_ from: Schema.Animation.Range<String>) throws -> VC.Animation.Range<VC.Mode<VC.Filling>> {
        try .init(
            start: filling(from.start),
            end: filling(from.end)
        )
    }
}

extension Schema.Animation.Range: Codable where T: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(T.self, forKey: .start)
        end = try container.decode(T.self, forKey: .end)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }
}
