//
//  VC.Asset.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyViewSource {
    enum Asset: Sendable {
        case filling(AdaptyViewConfiguration.Filling)
        case image(AdaptyViewConfiguration.ImageData)
        case video(AdaptyViewConfiguration.VideoData)
        case font(AdaptyViewConfiguration.Font)
        case unknown(String?)
    }
}

private extension AdaptyViewSource.Asset {
    var asFilling: AdaptyViewConfiguration.Filling {
        get throws {
            guard case let .filling(value) = self else {
                throw AdaptyViewLocalizerError.wrongTypeAsset("color or any-gradient")
            }
            return value
        }
    }

    var asColor: AdaptyViewConfiguration.Color {
        get throws {
            guard case let .filling(.solidColor(value)) = self else {
                throw AdaptyViewLocalizerError.wrongTypeAsset("color")
            }
            return value
        }
    }

    var asImageData: AdaptyViewConfiguration.ImageData {
        get throws {
            guard case let .image(value) = self else {
                throw AdaptyViewLocalizerError.wrongTypeAsset("image")
            }
            return value
        }
    }

    var asVideoData: AdaptyViewConfiguration.VideoData {
        get throws {
            guard case let .video(value) = self else {
                throw AdaptyViewLocalizerError.wrongTypeAsset("video")
            }
            return value
        }
    }

    var asFont: AdaptyViewConfiguration.Font {
        get throws {
            guard case let .font(value) = self else {
                throw AdaptyViewLocalizerError.wrongTypeAsset("font")
            }
            return value
        }
    }
}

extension AdaptyViewSource.Localizer {
    private enum AssetIdentifySuffix: String {
        case darkMode = "@dark"
    }

    private func asset(_ assetId: String, darkMode mode: Bool = false) throws -> AdaptyViewSource.Asset {
        guard let value = try assetOrNil(assetId, darkMode: mode) else {
            throw AdaptyViewLocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, darkMode mode: Bool) throws -> AdaptyViewSource.Asset? {
        let assetId = mode ? assetId + AssetIdentifySuffix.darkMode.rawValue : assetId
        return localization?.assets?[assetId] ?? source.assets[assetId]
    }

    @inlinable
    func background(_ assetId: String) throws -> AdaptyViewConfiguration.Background {
        switch try asset(assetId) {
        case let .filling(value):
            try .filling(.init(
                light: value,
                dark: assetOrNil(assetId, darkMode: true)?.asFilling
            ))
        case let .image(value):
            try .image(.init(
                light: value,
                dark: assetOrNil(assetId, darkMode: true)?.asImageData
            ))
        default:
            throw AdaptyViewLocalizerError.wrongTypeAsset("color, any-gradient, or image")
        }
    }

    @inlinable
    func filling(_ assetId: String) throws -> AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling> {
        try AdaptyViewConfiguration.Mode(
            light: asset(assetId).asFilling,
            dark: assetOrNil(assetId, darkMode: true)?.asFilling
        )
    }

    @inlinable
    func color(_ assetId: String) throws -> AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color> {
        try AdaptyViewConfiguration.Mode(
            light: asset(assetId).asColor,
            dark: try? assetOrNil(assetId, darkMode: true)?.asColor
        )
    }

    @inlinable
    func imageData(_ assetId: String) throws -> AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.ImageData> {
        try AdaptyViewConfiguration.Mode(
            light: asset(assetId).asImageData,
            dark: assetOrNil(assetId, darkMode: true)?.asImageData
        )
    }

    @inlinable
    func videoData(_ assetId: String) throws -> AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.VideoData> {
        try AdaptyViewConfiguration.Mode(
            light: asset(assetId).asVideoData,
            dark: assetOrNil(assetId, darkMode: true)?.asVideoData
        )
    }

    @inlinable
    func font(_ assetId: String) throws -> AdaptyViewConfiguration.Font {
        try asset(assetId).asFont
    }
}

extension AdaptyViewSource.Asset: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .filling(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .image(value):
            hasher.combine(value)
        case let .video(value):
            hasher.combine(value)
        case let .font(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .unknown(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

extension AdaptyViewSource.Asset: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }

        switch type {
        case let type where AdaptyViewConfiguration.Filling.assetType(type):
            self = try .filling(AdaptyViewConfiguration.Filling(from: decoder))
        case AdaptyViewConfiguration.Font.assetType:
            self = try .font(AdaptyViewConfiguration.Font(from: decoder))
        case AdaptyViewConfiguration.ImageData.assetType:
            self = try .image(AdaptyViewConfiguration.ImageData(from: decoder))
        case AdaptyViewConfiguration.VideoData.assetType:
            self = try .video(AdaptyViewConfiguration.VideoData(from: decoder))
        default:
            self = .unknown("asset.type: \(type)")
        }
    }

    func encode(to encoder: any Encoder) throws {
        switch self {
        case let .filling(value):
            try value.encode(to: encoder)
        case let .image(data):
            try data.encode(to: encoder)
        case let .video(data):
            try data.encode(to: encoder)
        case let .font(data):
            try data.encode(to: encoder)
        case .unknown:
            break
        }
    }
}

extension AdaptyViewSource {
    struct AssetsContainer: Codable {
        let value: [String: Asset]

        init(value: [String: Asset]) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let array = try decoder.singleValueContainer().decode([Item].self)
            value = try [String: Asset](array.map { ($0.id, $0.value) }, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate key"))
            })
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value.map(Item.init))
        }

        private struct Item: Codable {
            let id: String
            let value: Asset

            init(id: String, value: Asset) {
                self.id = id
                self.value = value
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: Asset.CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                value = try Asset(from: decoder)
            }

            func encode(to encoder: any Encoder) throws {
                try value.encode(to: encoder)
                var container = encoder.container(keyedBy: Asset.CodingKeys.self)
                try container.encode(id, forKey: .id)
            }
        }
    }
}
