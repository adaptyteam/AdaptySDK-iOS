//
//  Schema.Asset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Schema {
    enum Asset: Sendable {
        case filling(VC.Filling)
        case image(VC.ImageData)
        case video(VC.VideoData)
        case font(VC.Font)
        case unknown(String?)
    }
}

private extension Schema.Asset {
    var asFilling: VC.Filling {
        get throws {
            guard case let .filling(value) = self else {
                throw Schema.LocalizerError.wrongTypeAsset("color or any-gradient")
            }
            return value
        }
    }

    var asColor: VC.Color {
        get throws {
            guard case let .filling(.solidColor(value)) = self else {
                throw Schema.LocalizerError.wrongTypeAsset("color")
            }
            return value
        }
    }

    var asImageData: VC.ImageData {
        get throws {
            guard case let .image(value) = self else {
                throw Schema.LocalizerError.wrongTypeAsset("image")
            }
            return value
        }
    }

    var asVideoData: VC.VideoData {
        get throws {
            guard case let .video(value) = self else {
                throw Schema.LocalizerError.wrongTypeAsset("video")
            }
            return value
        }
    }

    var asFont: VC.Font {
        get throws {
            guard case let .font(value) = self else {
                throw Schema.LocalizerError.wrongTypeAsset("font")
            }
            return value
        }
    }
}

extension Schema.Localizer {
    private enum AssetIdentifySuffix: String {
        case darkMode = "@dark"
    }

    private func asset(_ assetId: String, darkMode mode: Bool = false) throws -> Schema.Asset {
        guard let value = assetOrNil(assetId, darkMode: mode) else {
            throw Schema.LocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, darkMode mode: Bool) -> Schema.Asset? {
        let assetId = mode ? assetId + AssetIdentifySuffix.darkMode.rawValue : assetId
        return localization?.assets?[assetId] ?? source.assets[assetId]
    }

    @inlinable
    func background(_ assetId: String) throws -> VC.Background {
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
            throw Schema.LocalizerError.wrongTypeAsset("color, any-gradient, or image")
        }
    }

    @inlinable
    func filling(_ assetId: String) throws -> VC.Mode<VC.Filling> {
        try VC.Mode(
            light: asset(assetId).asFilling,
            dark: assetOrNil(assetId, darkMode: true)?.asFilling
        )
    }

    @inlinable
    func color(_ assetId: String) throws -> VC.Mode<VC.Color> {
        try VC.Mode(
            light: asset(assetId).asColor,
            dark: try? assetOrNil(assetId, darkMode: true)?.asColor
        )
    }

    @inlinable
    func imageData(_ assetId: String) throws -> VC.Mode<VC.ImageData> {
        try VC.Mode(
            light: asset(assetId).asImageData,
            dark: assetOrNil(assetId, darkMode: true)?.asImageData
        )
    }

    @inlinable
    func videoData(_ assetId: String) throws -> VC.Mode<VC.VideoData> {
        try VC.Mode(
            light: asset(assetId).asVideoData,
            dark: assetOrNil(assetId, darkMode: true)?.asVideoData
        )
    }

    @inlinable
    func font(_ assetId: String) throws -> VC.Font {
        try asset(assetId).asFont
    }
}

extension Schema.Asset: Hashable {
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

extension Schema.Asset: Codable {
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
        case let type where VC.Filling.assetType(type):
            self = try .filling(VC.Filling(from: decoder))
        case VC.Font.assetType:
            self = try .font(VC.Font(from: decoder))
        case VC.ImageData.assetType:
            self = try .image(VC.ImageData(from: decoder))
        case VC.VideoData.assetType:
            self = try .video(VC.VideoData(from: decoder))
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

extension Schema {
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
