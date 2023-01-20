//
//  Asset.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    enum Asset {
        case color(AdaptyUI.Color)
        case image(AdaptyUI.Image)
        case font(AdaptyUI.Font)
        case unknown(String?)
    }
}

extension AdaptyUI.Asset: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
    }

    enum ContentType: String, Codable {
        case color
        case image
        case font
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }
        switch ContentType(rawValue: type) {
        case .color:
            self = .color(try container.decode(AdaptyUI.Color.self, forKey: .value))
        case .font:
            self = .font(try decoder.singleValueContainer().decode(AdaptyUI.Font.self))
        case .image:
            self = .image(try decoder.singleValueContainer().decode(AdaptyUI.Image.self))
        default:
            self = .unknown("asset.type: \(type)")
        }
    }
}

extension AdaptyUI {
    struct Assets: Decodable {
        let value: [String: AdaptyUI.Asset]

        init(from decoder: Decoder) throws {
            let array = try decoder.singleValueContainer().decode([Item].self)
            value = Dictionary(uniqueKeysWithValues: array.map { ($0.id, $0.value) })
        }

        fileprivate struct Item: Decodable {
            let id: String
            let value: AdaptyUI.Asset

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: AdaptyUI.Asset.CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                value = try decoder.singleValueContainer().decode(AdaptyUI.Asset.self)
            }
        }
    }
}
