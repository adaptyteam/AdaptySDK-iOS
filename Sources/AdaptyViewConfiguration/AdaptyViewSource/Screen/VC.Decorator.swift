//
//  VC.Decorator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Decorator: Sendable, Hashable {
        let shapeType: AdaptyViewConfiguration.ShapeType
        let backgroundAssetId: String?
        let borderAssetId: String?
        let borderThickness: Double?
    }
}

extension AdaptyViewSource.Localizer {
    func decorator(_ from: AdaptyViewSource.Decorator) throws -> AdaptyViewConfiguration.Decorator {
        .init(
            shapeType: from.shapeType,
            background: from.backgroundAssetId.flatMap { try? background($0) },
            border: from.borderAssetId.map { (try? filling($0)) ?? AdaptyViewConfiguration.Border.default.filling }.map {
                AdaptyViewConfiguration.Border(filling: $0, thickness: from.borderThickness ?? AdaptyViewConfiguration.Border.default.thickness)
            }
        )
    }
}

extension AdaptyViewSource.Decorator: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case shapeType = "type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decodeIfPresent(String.self, forKey: .backgroundAssetId)
        let shape = (try? container.decode(AdaptyViewConfiguration.ShapeType.self, forKey: .shapeType)) ?? AdaptyViewConfiguration.Decorator.defaultShapeType

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(AdaptyViewConfiguration.CornerRadius.self, forKey: .rectangleCornerRadius) {
            shapeType = .rectangle(cornerRadius: rectangleCornerRadius)
        } else {
            shapeType = shape
        }

        if let assetId = try container.decodeIfPresent(String.self, forKey: .borderAssetId) {
            borderAssetId = assetId
            borderThickness = try container.decodeIfPresent(Double.self, forKey: .borderThickness)
        } else {
            borderAssetId = nil
            borderThickness = nil
        }
    }
}
