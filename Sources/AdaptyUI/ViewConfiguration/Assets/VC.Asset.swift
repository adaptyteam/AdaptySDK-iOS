//
//  VC.Asset.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum Asset {
        case filling(AdaptyUI.Filling)
        case font(AdaptyUI.Font)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewConfiguration.Asset {
    var asFont: AdaptyUI.Font? {
        guard  case let .font(value) = self else { return nil }
        return value
    }
    
    var asFilling: AdaptyUI.Filling? {
        guard  case let .filling(value) = self else { return nil }
        return value
    }
}

extension AdaptyUI.ViewConfiguration.Asset: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
    }

    enum ContentType: String, Codable {
        case color
        case image
        case font
        case colorLinearGradient = "linear-gradient"
        case colorRadialGradient = "radial-gradient"
        case colorConicGradient = "conic-gradient"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }
        switch ContentType(rawValue: type) {
        case .color:
            self = try .filling(.color(container.decode(AdaptyUI.Color.self, forKey: .value)))
        case .colorLinearGradient,
             .colorRadialGradient,
             .colorConicGradient:
            self = try .filling(.colorGradient(AdaptyUI.ColorGradient(from: decoder)))
        case .font:
            self = try .font(AdaptyUI.Font(from: decoder))
        case .image:
            self = try .filling(.image(AdaptyUI.Image(from: decoder)))
        default:
            self = .unknown("asset.type: \(type)")
        }
    }
}

extension AdaptyUI.ViewConfiguration {
    struct AssetsContainer: Decodable {
        let value: [String: Asset]

        init(from decoder: Decoder) throws {
            struct Item: Decodable {
                let id: String
                let value: Asset

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: Asset.CodingKeys.self)
                    id = try container.decode(String.self, forKey: .id)
                    value = try decoder.singleValueContainer().decode(Asset.self)
                }
            }

            let array = try decoder.singleValueContainer().decode([Item].self)
            value = try [String: Asset](array.map { ($0.id, $0.value) }, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate key"))
            })
        }
    }
}
