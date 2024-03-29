//
//  VC.TextBlock.swift
//  AdaptyUI
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

extension AdaptyUI.ViewConfiguration.Localizer {
    func richText(_ textBlock: AdaptyUI.ViewConfiguration.TextBlock) -> AdaptyUI.RichText {
        richTextIfPresent(textBlock) ?? AdaptyUI.RichText.empty
    }

    func richTextIfPresent(_ textBlock: AdaptyUI.ViewConfiguration.TextBlock) -> AdaptyUI.RichText? {
        guard let item = localization?.strings?[textBlock.stringId] else { return nil }
        return .init(
            items: item.value.convert(
                self,
                defaultTextAttributes: textBlock.textAttributes,
                defaultParagraphAttributes: textBlock.paragraphAttributes
            ),
            fallback: item.fallback.map { $0.convert(
                self,
                defaultTextAttributes: textBlock.textAttributes,
                defaultParagraphAttributes: textBlock.paragraphAttributes
            ) },
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
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
