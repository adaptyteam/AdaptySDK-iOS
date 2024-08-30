//
//  VC.Asset.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum Asset: Sendable {
        case filling(AdaptyUI.Filling)
        case image(AdaptyUI.ImageData)
        case video(AdaptyUI.VideoData)
        case font(AdaptyUI.Font)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    private func asset(_ assetId: String) throws -> AdaptyUI.ViewConfiguration.Asset {
        guard let value = localization?.assets?[assetId] ?? source.assets[assetId] else {
            throw AdaptyUI.LocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    @inlinable
    func background(_ assetId: String) throws -> AdaptyUI.Background {
        switch try asset(assetId) {
        case let .filling(value):
            .filling(value)
        case let .image(value):
            .image(value)
        default:
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "color, any-gradient, or image")
        }
    }

    @inlinable
    func color(_ assetId: String) throws -> AdaptyUI.Color {
        guard case let .filling(value) = try asset(assetId), let color = value.asColor else {
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "color")
        }
        return color
    }

    @inlinable
    func filling(_ assetId: String) throws -> AdaptyUI.Filling {
        guard case let .filling(value) = try asset(assetId) else {
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "color or any-gradient")
        }
        return value
    }

    @inlinable
    func imageData(_ assetId: String) throws -> AdaptyUI.ImageData {
        guard case let .image(value) = try asset(assetId) else {
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "color")
        }
        return value
    }

    @inlinable
    func videoData(_ assetId: String) throws -> AdaptyUI.VideoData {
        guard case let .video(value) = try asset(assetId) else {
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "video")
        }
        return value
    }

    @inlinable
    func font(_ assetId: String) throws -> AdaptyUI.Font {
        guard case let .font(value) = try asset(assetId) else {
            throw AdaptyUI.LocalizerError.wrongTypeAsset(assetId, expected: "font")
        }
        return value
    }
}

extension AdaptyUI.ViewConfiguration.Asset: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .filling(value):
            hasher.combine(value)
        case let .image(value):
            hasher.combine(value)
        case let .video(value):
            hasher.combine(value)
        case let .font(value):
            hasher.combine(value)
        case let .unknown(value):
            hasher.combine(value)
        }
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
        case video
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
        case .video:
            self = try .video(AdaptyUI.VideoData(from: decoder))
        case .image:
            self = try .image(AdaptyUI.ImageData(from: decoder))
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
