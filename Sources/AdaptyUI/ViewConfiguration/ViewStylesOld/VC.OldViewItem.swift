//
//  VC.OldViewItem.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum OldViewItem {
        case asset(String)
        case shape(Decorator)
        case button(OldButton)
        case text(Text)
        case object(OldCustomObject)
        case unknown
    }
}

extension AdaptyUI.ViewConfiguration.OldViewItem: Decodable {
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
            self = try .shape(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.Decorator.self))
        case .button:
            self = try .button(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.OldButton.self))
        case .text:
            self = try .text(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.Text.self))
        default:
            self = try .object(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.OldCustomObject.self))
        }
    }
}
