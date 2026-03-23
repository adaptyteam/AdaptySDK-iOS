//
//  Schema.AffineTransform.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.03.2026.
//

extension Schema {
    typealias AffineTransform = VC.AffineTransform
}

extension Schema.AffineTransform: Codable {
    enum CodingKeys: String, CodingKey {
        case a
        case b
        case c
        case d
        case x
        case y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            a: container.decodeIfPresent(Double.self, forKey: .a) ?? 1,
            b: container.decodeIfPresent(Double.self, forKey: .b) ?? 0,
            c: container.decodeIfPresent(Double.self, forKey: .c) ?? 0,
            d: container.decodeIfPresent(Double.self, forKey: .d) ?? 1,
            x: container.decodeIfPresent(Schema.Unit.self, forKey: .x) ?? .zero,
            y: container.decodeIfPresent(Schema.Unit.self, forKey: .y) ?? .zero
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let (a, b, c, d, x, y) = full
        if a != 1 {
            try container.encode(a, forKey: .a)
        }
        if b != 0 {
            try container.encode(b, forKey: .b)
        }
        if c != 0 {
            try container.encode(c, forKey: .c)
        }
        if d != 1 {
            try container.encode(d, forKey: .d)
        }
        if !x.isZero {
            try container.encode(x, forKey: .x)
        }
        if !y.isZero {
            try container.encode(y, forKey: .y)
        }
    }
}

