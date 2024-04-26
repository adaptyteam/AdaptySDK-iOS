//
//  Unit.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package enum Unit {
        case point(Double)
        case screen(Double)
    }
}

extension AdaptyUI.Unit {
    package func points(scrrenInPoints: Double) -> Double {
        switch self {
        case let .point(value): value
        case let .screen(value): value * scrrenInPoints
        }
    }
}

extension AdaptyUI.Unit: Decodable {
    enum CodingKeys: String, CodingKey {
        case value
        case unit
        case point
        case screen
    }

    package init(from decoder: any Decoder) throws {
        if let points = try? decoder.singleValueContainer().decode(Double.self) {
            self = .point(points)
        } else {
            let conteineer = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try conteineer.decodeIfPresent(Double.self, forKey: .screen) {
                self = .screen(value)
            } else if let value = try conteineer.decodeIfPresent(Double.self, forKey: .point) {
                self = .point(value)
            } else {
                let value = try conteineer.decode(Double.self, forKey: .value)
                let unit = try conteineer.decodeIfPresent(String.self, forKey: .unit)
                switch unit {
                case .some(CodingKeys.screen.rawValue):
                    self = .screen(value)
                case .some(CodingKeys.point.rawValue), .none:
                    self = .point(value)
                default:
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: conteineer.codingPath + [CodingKeys.unit], debugDescription: "usupport value: \(unit ?? "null")"))
                }
            }
        }
    }
}
