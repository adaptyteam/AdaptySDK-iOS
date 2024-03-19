//
//  VC.Shape.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Shape {
        let backgroundAssetId: String?
        let type: AdaptyUI.ShapeType
        let borderAssetId: String?
        let borderThickness: Double?
    }
}

extension AdaptyUI.ViewConfiguration.Shape {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?) -> AdaptyUI.Shape {
        var border: AdaptyUI.Shape.Border?
        if let filling = assetById(borderAssetId)?.asFilling {
            border = .init(filling: filling, thickness: borderThickness ?? AdaptyUI.Shape.Border.defaultThickness)
        }
        return .init(
            background: assetById(backgroundAssetId)?.asFilling,
            border: border,
            type: type
        )
    }
}

extension AdaptyUI.ViewConfiguration.Shape: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decodeIfPresent(String.self, forKey: .backgroundAssetId)
        let shape: AdaptyUI.ShapeType =
            if let value = try? container.decode(AdaptyUI.ShapeType.self, forKey: .type) {
                value
            } else if let value = try container.decodeIfPresent(AdaptyUI.ShapeType.self, forKey: .value) {
                value
            } else {
                AdaptyUI.Shape.defaultType
            }

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(AdaptyUI.Shape.CornerRadius.self, forKey: .rectangleCornerRadius) {
            type = .rectangle(cornerRadius: rectangleCornerRadius)
        } else {
            type = shape
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
