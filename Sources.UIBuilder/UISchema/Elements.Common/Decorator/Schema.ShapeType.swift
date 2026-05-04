//
//  Schema.ShapeType.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias ShapeType = VC.ShapeType
}

extension Schema.ShapeType {
    static let `default` = Self.rectangle(cornerRadius: .zero)
}

extension Schema.ShapeType: Decodable {
    enum Types: String {
        case circle
        case rectangle = "rect"
        case curveUp = "curve_up"
        case curveDown = "curve_down"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try Types(rawValue: container.decode(String.self)) {
        case nil:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        case .curveUp:
            self = .curveUp
        case .curveDown:
            self = .curveDown
        case .rectangle:
            self = .rectangle(cornerRadius: Schema.CornerRadius.zero)
        case .circle:
            self = .circle
        }
    }
}
