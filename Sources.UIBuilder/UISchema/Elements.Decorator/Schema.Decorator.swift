//
//  Schema.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Decorator: Sendable, Hashable {
        let shapeType: ShapeType
        let backgroundAssetId: String?
        let borderAssetId: String?
        let borderThickness: Double?
        let shadow: Shadow?
    }
}

extension Schema.Localizer {
    func decorator(_ from: Schema.Decorator) -> VC.Decorator {
        .init(
            shapeType: from.shapeType,
            background: from.backgroundAssetId.flatMap { try? background($0) },
            border: from.borderAssetId.map { (try? filling($0)) ?? Schema.Border.default.filling }.map {
                VC.Border(filling: $0, thickness: from.borderThickness ?? Schema.Border.default.thickness)
            },
            shadow: from.shadow.flatMap { try? shadow($0) }
        )
    }
}

extension Schema.Decorator: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case shapeType = "type"
        case shadow
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decodeIfPresent(String.self, forKey: .backgroundAssetId)
        let shape = (try? container.decode(Schema.ShapeType.self, forKey: .shapeType)) ?? .default

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(Schema.CornerRadius.self, forKey: .rectangleCornerRadius)
        {
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

        shadow = try container.decodeIfPresent(Schema.Shadow.self, forKey: .shadow)
    }
}
