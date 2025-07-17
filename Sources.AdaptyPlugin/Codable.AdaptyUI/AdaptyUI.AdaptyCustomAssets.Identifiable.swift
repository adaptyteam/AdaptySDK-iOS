//
//  AdaptyUI.CustomAssets.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.05.2025.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyCustomAsset {
    struct Identifiable {
        let id: String
        let value: Value
    }

    enum Value {
        case asset(AdaptyCustomAsset)
        case imageFlutterAssetId(String)
        case videoFlutterAssetId(String)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyCustomAsset.Identifiable: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
        case path
        case flutterAssetId = "asset_id"
    }

    enum TypeValueConstants: String, Decodable {
        case color
        case linearGradient = "linear-gradient"
        case image
        case video
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(TypeValueConstants.self, forKey: .type)

        switch type {
        case .color:
            let color = try container.decode(AdaptyViewConfiguration.Color.self, forKey: .value)
            value = .asset(color.asCustomAsset)

        case .linearGradient:
            let gradient = try AdaptyViewConfiguration.ColorGradient(from: decoder)
            value = .asset(gradient.asCustomAsset)

        case .image:
            if let data = try container.decodeIfPresent(Data.self, forKey: .value) {
                if let image = UIImage(data: data) {
                    value = .asset(.image(.uiImage(value: image)))
                } else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Image data is corrupted, cannot create UIImage"))
                }
            } else if let path = try container.decodeIfPresent(String.self, forKey: .path) {
                value = .asset(.image(.file(url: path.asFileURL)))
            } else if let flutterAssetId = try container.decodeIfPresent(String.self, forKey: .flutterAssetId) {
                value = .imageFlutterAssetId(flutterAssetId)
            } else {
                throw DecodingError.keyNotFound(CodingKeys.value, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Corrupted Image asset, not found value or path"))
            }

        case .video:
            if let path = try container.decodeIfPresent(String.self, forKey: .path) {
                value = .asset(.video(.file(url: path.asFileURL, preview: nil)))
            } else if let flutterAssetId = try container.decodeIfPresent(String.self, forKey: .flutterAssetId) {
                value = .videoFlutterAssetId(flutterAssetId)
            } else {
                throw DecodingError.keyNotFound(CodingKeys.path, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Corrupted video asset, not found path"))
            }
        }
    }
}

private extension String {
    var asFileURL: URL {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            URL(filePath: self)
        } else {
            URL(fileURLWithPath: self)
        }
    }
}

#endif
