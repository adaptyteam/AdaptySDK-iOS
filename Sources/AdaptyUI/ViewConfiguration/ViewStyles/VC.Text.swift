//
//  VC.Text.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Text {
        let stringId: String
        let textAttributes: TextAttributes?
        let paragraphAttributes: ParagraphAttributes?
        let imageInTextAttributes: ImageInTextAttributes?
    }
}

extension AdaptyUI.ViewConfiguration.RichText {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?, def: AdaptyUI.ViewConfiguration.Text?) -> [AdaptyUI.RichText.Item] {
        convert(
            assetById,
            defTextAttributes: def?.textAttributes,
            defParagraphAttributes: def?.paragraphAttributes,
            defImageInTextAttributes: def?.imageInTextAttributes
        )
    }
}

extension AdaptyUI.ViewConfiguration.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case paragraphAttributes = "paragraph_attributes"
        case imageInTextAttributes = "image_attributes"
    }

    init(from decoder: Decoder) throws {
        if let id = try? decoder.singleValueContainer().decode(String.self) {
            stringId = id
            textAttributes = nil
            paragraphAttributes = nil
            imageInTextAttributes = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(String.self, forKey: .stringId)

        textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        paragraphAttributes = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.ParagraphAttributes.self, forKey: .paragraphAttributes)
        imageInTextAttributes = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.ImageInTextAttributes.self, forKey: .imageInTextAttributes)
    }
}
