//
//  VC.OldViewItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum OldViewItem {
        case asset(String)
        case shape(Decorator)
        case button(OldButton)
        case text(OldText)
        case object(OldCustomObject)
        case unknown
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func orderedOldViewItems(_ from: [(key: String, value: AdaptyUI.ViewConfiguration.OldViewItem)]) -> [(key: String, value: AdaptyUI.OldViewItem)] {
        from.map { (key: $0.key, value: oldViewItem($0.value)) }
    }

    func oldViewItem(_ from: AdaptyUI.ViewConfiguration.OldViewItem) -> AdaptyUI.OldViewItem {
        switch from {
        case let .asset(id):
            guard let asset = assetIfPresent(id) else {
                return .unknown("asset.id: \(id)")
            }
            switch asset {
            case let .filling(value):
                return .filling(value)
            case let .unknown(value):
                return .unknown(value)
            case .font:
                return .unknown("unsupported asset {type: font, id: \(id)}")
            }
        case let .shape(value):
            return .shape(decorator(value))
        case let .button(value):
            return .button(oldButton(value))
        case let .text(value):
            return .text(richText(value))
        case let .object(value):
            return .object(oldCustomObject(value))
        case .unknown:
            return .unknown("unsupported type")
        }
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
            self = try .text(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.OldText.self))
        default:
            self = try .object(decoder.singleValueContainer().decode(AdaptyUI.ViewConfiguration.OldCustomObject.self))
        }
    }
}
