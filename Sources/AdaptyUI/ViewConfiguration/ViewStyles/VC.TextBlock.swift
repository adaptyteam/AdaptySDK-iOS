//
//  VC.TextBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct TextBlock {
        let stringId: String
        let maxRows: Int?
        let overflowMode: Set<AdaptyUI.RichText.OverflowMode>
        let textAttributes: TextAttributes?
        let paragraphAttributes: ParagraphAttributes?
    }
}

extension AdaptyUI.ViewConfiguration.TextBlock {
    func convert(
        _ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?,
        item: AdaptyUI.ViewConfiguration.Localization.Item
    ) -> AdaptyUI.RichText {
        AdaptyUI.RichText(
            items: item.value.convert(
                assetById,
                defaultTextAttributes: textAttributes,
                defaultParagraphAttributes: paragraphAttributes
            ),
            fallback: item.fallback.map { $0.convert(
                assetById,
                defaultTextAttributes: textAttributes,
                defaultParagraphAttributes: paragraphAttributes
            ) },
            maxRows: maxRows,
            overflowMode: overflowMode
        )
    }
}

extension AdaptyUI.ViewConfiguration.TextBlock: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        if let id = try? decoder.singleValueContainer().decode(String.self) {
            stringId = id
            textAttributes = nil
            paragraphAttributes = nil
            maxRows = nil
            overflowMode = AdaptyUI.RichText.OverflowMode.empty
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(String.self, forKey: .stringId)
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(AdaptyUI.RichText.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([AdaptyUI.RichText.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        self.textAttributes = textAttributes.isEmpty ? nil : textAttributes
        let paragraphAttributes = try AdaptyUI.ViewConfiguration.ParagraphAttributes(from: decoder)
        self.paragraphAttributes = paragraphAttributes.isEmpty ? nil : paragraphAttributes
    }
}
