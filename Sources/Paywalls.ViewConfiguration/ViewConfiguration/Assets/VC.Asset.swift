//
//  VC.Asset.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    enum Asset: Sendable {
        case filling(AdaptyUICore.Filling)
        case image(AdaptyUICore.ImageData)
        case video(AdaptyUICore.VideoData)
        case font(AdaptyUICore.Font)
        case unknown(String?)
    }
}

private extension AdaptyUICore.ViewConfiguration.Asset {
    var asFilling: AdaptyUICore.Filling {
        get throws {
            guard case let .filling(value) = self else {
                throw AdaptyUICore.LocalizerError.wrongTypeAsset("color or any-gradient")
            }
            return value
        }
    }

    var asColor: AdaptyUICore.Color {
        get throws {
            guard case let .filling(.solidColor(value)) = self else {
                throw AdaptyUICore.LocalizerError.wrongTypeAsset("color")
            }
            return value
        }
    }

    var asImageData: AdaptyUICore.ImageData {
        get throws {
            guard case let .image(value) = self else {
                throw AdaptyUICore.LocalizerError.wrongTypeAsset("image")
            }
            return value
        }
    }

    var asVideoData: AdaptyUICore.VideoData {
        get throws {
            guard case let .video(value) = self else {
                throw AdaptyUICore.LocalizerError.wrongTypeAsset("video")
            }
            return value
        }
    }

    var asFont: AdaptyUICore.Font {
        get throws {
            guard case let .font(value) = self else {
                throw AdaptyUICore.LocalizerError.wrongTypeAsset("font")
            }
            return value
        }
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    private enum AssetIdentifySufix: String {
        case darkMode = "@dark"
    }

    private func asset(_ assetId: String, darkMode mode: Bool = false) throws -> AdaptyUICore.ViewConfiguration.Asset {
        guard let value = try assetOrNil(assetId, darkMode: mode) else {
            throw AdaptyUICore.LocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, darkMode mode: Bool) throws -> AdaptyUICore.ViewConfiguration.Asset? {
        let assetId = mode ? assetId + AssetIdentifySufix.darkMode.rawValue : assetId
        return localization?.assets?[assetId] ?? source.assets[assetId]
    }

    @inlinable
    func background(_ assetId: String) throws -> AdaptyUICore.Background {
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
            throw AdaptyUICore.LocalizerError.wrongTypeAsset("color, any-gradient, or image")
        }
    }

    @inlinable
    func filling(_ assetId: String) throws -> AdaptyUICore.Mode<AdaptyUICore.Filling> {
        try AdaptyUICore.Mode(
            light: asset(assetId).asFilling,
            dark: assetOrNil(assetId, darkMode: true)?.asFilling
        )
    }

    @inlinable
    func color(_ assetId: String) throws -> AdaptyUICore.Mode<AdaptyUICore.Color> {
        try AdaptyUICore.Mode(
            light: asset(assetId).asColor,
            dark: try? assetOrNil(assetId, darkMode: true)?.asColor
        )
    }

    @inlinable
    func imageData(_ assetId: String) throws -> AdaptyUICore.Mode<AdaptyUICore.ImageData> {
        try AdaptyUICore.Mode(
            light: asset(assetId).asImageData,
            dark: assetOrNil(assetId, darkMode: true)?.asImageData
        )
    }

    @inlinable
    func videoData(_ assetId: String) throws -> AdaptyUICore.Mode<AdaptyUICore.VideoData> {
        try AdaptyUICore.Mode(
            light: asset(assetId).asVideoData,
            dark: assetOrNil(assetId, darkMode: true)?.asVideoData
        )
    }

    @inlinable
    func font(_ assetId: String) throws -> AdaptyUICore.Font {
        try asset(assetId).asFont
    }
}

extension AdaptyUICore.ViewConfiguration.Asset: Hashable {
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

extension AdaptyUICore.ViewConfiguration.Asset: Decodable {
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
        case let type where AdaptyUICore.Filling.assetType(type):
            self = try .filling(AdaptyUICore.Filling(from: decoder))
        case AdaptyUICore.Font.assetType:
            self = try .font(AdaptyUICore.Font(from: decoder))
        case AdaptyUICore.ImageData.assetType:
            self = try .image(AdaptyUICore.ImageData(from: decoder))
        case AdaptyUICore.VideoData.assetType:
            self = try .video(AdaptyUICore.VideoData(from: decoder))
        default:
            self = .unknown("asset.type: \(type)")
        }
    }
}

extension AdaptyUICore.ViewConfiguration {
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
