//
//  Asset.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public enum Asset {
        case color(AdaptyUI.Color)
        case image(Image)
        case font(Font)
        case unknown(String)
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(ContentType.self, forKey: .type) {
        case .color:
            self = .color(try container.decode(AdaptyUI.Color.self, forKey: .value))
        case .font:
            self = .font(try decoder.singleValueContainer().decode(Font.self))
        case .image:
            self = .image(try decoder.singleValueContainer().decode(Image.self))
        }
    }
 }

 extension AdaptyUI {
    struct Assets {
        let value: [String: Asset]
    }
 }

 extension AdaptyUI.Assets: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var assets = [String: AdaptyUI.Asset]()
        if let count = container.count {
            assets.reserveCapacity(count)
        }
        while !container.isAtEnd {
            let item = try container.nestedContainer(keyedBy: AdaptyUI.Asset.CodingKeys.self)
            let id = try item.decode(String.self, forKey: .id)
            let singleContainer = try item.superDecoder().singleValueContainer()
            assets[id] = try singleContainer.decode(AdaptyUI.Asset.self)
        }
        value = assets
    }
 }
