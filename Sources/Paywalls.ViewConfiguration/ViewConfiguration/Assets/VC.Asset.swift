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

private extension AdaptyUI.ViewConfiguration.Asset {
    var asFilling: AdaptyUI.Filling {
        get throws {
            guard case let .filling(value) = self else {
                throw AdaptyUI.LocalizerError.wrongTypeAsset("color or any-gradient")
            }
            return value
        }
    }

    var asColor: AdaptyUI.Color {
        get throws {
            guard case let .filling(.solidColor(value)) = self else {
                throw AdaptyUI.LocalizerError.wrongTypeAsset("color")
            }
            return value
        }
    }

    var asImageData: AdaptyUI.ImageData {
        get throws {
            guard case let .image(value) = self else {
                throw AdaptyUI.LocalizerError.wrongTypeAsset("image")
            }
            return value
        }
    }

    var asVideoData: AdaptyUI.VideoData {
        get throws {
            guard case let .video(value) = self else {
                throw AdaptyUI.LocalizerError.wrongTypeAsset("video")
            }
            return value
        }
    }

    var asFont: AdaptyUI.Font {
        get throws {
            guard case let .font(value) = self else {
                throw AdaptyUI.LocalizerError.wrongTypeAsset("font")
            }
            return value
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    private enum AssetIdentifySufix: String {
        case darkMode = "@dark"
    }

    private func asset(_ assetId: String, darkMode mode: Bool = false) throws -> AdaptyUI.ViewConfiguration.Asset {
        guard let value = try assetOrNil(assetId, darkMode: mode) else {
            throw AdaptyUI.LocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, darkMode mode: Bool) throws -> AdaptyUI.ViewConfiguration.Asset? {
        let assetId = mode ? assetId + AssetIdentifySufix.darkMode.rawValue : assetId
        return localization?.assets?[assetId] ?? source.assets[assetId]
    }

    @inlinable
    func background(_ assetId: String) throws -> AdaptyUI.Background {
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
            throw AdaptyUI.LocalizerError.wrongTypeAsset("color, any-gradient, or image")
        }
    }

    @inlinable
    func filling(_ assetId: String) throws -> AdaptyUI.Mode<AdaptyUI.Filling> {
        try AdaptyUI.Mode(
            light: asset(assetId).asFilling,
            dark: assetOrNil(assetId, darkMode: true)?.asFilling
        )
    }

    @inlinable
    func color(_ assetId: String) throws -> AdaptyUI.Mode<AdaptyUI.Color> {
        try AdaptyUI.Mode(
            light: asset(assetId).asColor,
            dark: try? assetOrNil(assetId, darkMode: true)?.asColor
        )
    }

    @inlinable
    func imageData(_ assetId: String) throws -> AdaptyUI.Mode<AdaptyUI.ImageData> {
        try AdaptyUI.Mode(
            light: asset(assetId).asImageData,
            dark: assetOrNil(assetId, darkMode: true)?.asImageData
        )
    }

    @inlinable
    func videoData(_ assetId: String) throws -> AdaptyUI.Mode<AdaptyUI.VideoData> {
        try AdaptyUI.Mode(
            light: asset(assetId).asVideoData,
            dark: assetOrNil(assetId, darkMode: true)?.asVideoData
        )
    }

    @inlinable
    func font(_ assetId: String) throws -> AdaptyUI.Font {
        try asset(assetId).asFont
    }
}

extension AdaptyUI.ViewConfiguration.Asset: Hashable {
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

extension AdaptyUI.ViewConfiguration.Asset: Decodable {
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
        case let type where AdaptyUI.Filling.assetType(type):
            self = try .filling(AdaptyUI.Filling(from: decoder))
        case AdaptyUI.Font.assetType:
            self = try .font(AdaptyUI.Font(from: decoder))
        case AdaptyUI.ImageData.assetType:
            self = try .image(AdaptyUI.ImageData(from: decoder))
        case AdaptyUI.VideoData.assetType:
            self = try .video(AdaptyUI.VideoData(from: decoder))
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
