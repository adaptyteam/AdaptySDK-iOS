//
//  Schema.Rotation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

extension Schema {
    typealias Rotation = VC.Rotation
}

extension Schema.Rotation {
    static let zero = Self(angle: 0, anchor: .center)
}

extension Schema.Rotation: Decodable {
    enum CodingKeys: String, CodingKey {
        case angle
        case anchor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            angle: container.decode(Double.self, forKey: .angle),
            anchor: container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
        )
    }
}
