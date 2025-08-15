//
//  VC.Shadow.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyViewSource {
    struct Shadow: Sendable, Hashable {
        let colorAssetId: String
        let blurRadius: Double
        let offset: AdaptyViewConfiguration.Offset
    }
}

extension AdaptyViewSource.Localizer {
    func shadow(_ from: AdaptyViewSource.Shadow) throws -> AdaptyViewConfiguration.Shadow {
        .init(
            filling: (try? filling(from.colorAssetId)) ?? AdaptyViewConfiguration.Shadow.default.filling,
            blurRadius: from.blurRadius,
            offset: from.offset
        )
    }
}

extension AdaptyViewSource.Shadow: Decodable {
    enum CodingKeys: String, CodingKey {
        case colorAssetId = "color"
        case blurRadius = "blur_radius"
        case offset
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        colorAssetId = try container.decode(String.self, forKey: .colorAssetId)

        blurRadius = try container.decodeIfPresent(Double.self, forKey: .blurRadius) ?? AdaptyViewConfiguration.Shadow.default.blurRadius

        offset = try container.decodeIfPresent(AdaptyViewConfiguration.Offset.self, forKey: .offset) ?? AdaptyViewConfiguration.Shadow.default.offset
    }
}
