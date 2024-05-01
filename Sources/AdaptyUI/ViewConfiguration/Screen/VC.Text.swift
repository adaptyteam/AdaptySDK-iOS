//
//  VC.Text.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Text {
        let stringId: StringId
        let maxRows: Int?
        let overflowMode: Set<AdaptyUI.Text.OverflowMode>
        let textAttributes: TextAttributes?
        let paragraphAttributes: ParagraphAttributes?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func text(_ textBlock: AdaptyUI.ViewConfiguration.Text) -> AdaptyUI.Text {
        textIfPresent(textBlock) ?? AdaptyUI.Text.empty
    }

    func textIfPresent(_ textBlock: AdaptyUI.ViewConfiguration.Text) -> AdaptyUI.Text? {
        guard let item = localization?.strings?[textBlock.stringId] else { return nil }

        let text = AdaptyUI.RichText(
            items: item.value.convert(
                self,
                defaultTextAttributes: textBlock.textAttributes,
                defaultParagraphAttributes: textBlock.paragraphAttributes
            ),
            fallback: item.fallback.map { $0.convert(
                self,
                defaultTextAttributes: textBlock.textAttributes,
                defaultParagraphAttributes: textBlock.paragraphAttributes
            ) }
        )

        let value: AdaptyUI.Text.Value = text.isEmpty ? .empty : .text(text)

        return AdaptyUI.Text(
            value: value,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension AdaptyUI.ViewConfiguration.Text: Decodable {
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
            overflowMode = AdaptyUI.Text.OverflowMode.empty
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(AdaptyUI.ViewConfiguration.StringId.self, forKey: .stringId)
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(AdaptyUI.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([AdaptyUI.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        self.textAttributes = textAttributes.isEmpty ? nil : textAttributes
        let paragraphAttributes = try AdaptyUI.ViewConfiguration.ParagraphAttributes(from: decoder)
        self.paragraphAttributes = paragraphAttributes.isEmpty ? nil : paragraphAttributes
    }
}
