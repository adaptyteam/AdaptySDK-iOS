//
//  VC.ViewItem.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum ViewItem {
        case asset(String)
        case shape(Shape)
        case button(Button)
        case text(Text)
        case object(CustomObject)
        case unknown
    }
}

extension AdaptyUI.ViewConfiguration.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
        case text
        case shape
        case rectangle = "rect"
        case circle
        case curveUp = "curve_up"
        case curveDown = "curve_down"
        case button
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let assetId = try? single.decode(String.self) {
            self = .asset(assetId)
            return
        }

        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = .unknown
            return
        }

        let type = try container.decode(String.self, forKey: .type)

        switch ContentType(rawValue: type) {
        case .shape, .rectangle, .circle, .curveUp, .curveDown:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.Button.self))
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.Text.self))
        default:
            self = .object(try decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.CustomObject.self))
        }
    }
}
