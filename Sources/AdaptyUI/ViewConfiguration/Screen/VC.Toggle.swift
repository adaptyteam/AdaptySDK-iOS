//
//  VC.Toggle.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Toggle {
        let sectionId: String
        let onIndex: Int
        let offIndex: Int
        let colorAssetId: String?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func toggle(_ from: AdaptyUI.ViewConfiguration.Toggle) throws -> AdaptyUI.Toggle {
        .init(
            sectionId: from.sectionId,
            onIndex: from.onIndex,
            offIndex: from.offIndex,
            color: fillingIfPresent(from.colorAssetId)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Toggle: Decodable {
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case onIndex = "on_index"
        case offIndex = "off_index"
        case colorAssetId = "color"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            sectionId: container.decode(String.self, forKey: .sectionId),
            onIndex: container.decodeIfPresent(Int.self, forKey: .onIndex) ?? 0,
            offIndex: container.decodeIfPresent(Int.self, forKey: .offIndex) ?? -1,
            colorAssetId: container.decodeIfPresent(String.self, forKey: .colorAssetId)
        )
    }
}
