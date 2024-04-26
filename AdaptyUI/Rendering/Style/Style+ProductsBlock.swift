//
//  Style+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import Foundation

extension AdaptyUI {
    struct ProductInfo {
        let id: String
        let title: AdaptyUI.RichText?

        let subtitle: AdaptyUI.RichText?
        let subtitlePayAsYouGo: AdaptyUI.RichText?
        let subtitlePayUpFront: AdaptyUI.RichText?
        let subtitleFreeTrial: AdaptyUI.RichText?

        let secondTitle: AdaptyUI.RichText?
        let secondSubitle: AdaptyUI.RichText?

        let button: AdaptyUI.OldButton?
        let tagText: AdaptyUI.RichText?
        let tagShape: AdaptyUI.Decorator?
    }
}

extension AdaptyUI.OldProductObject {
    func toProductInfo(id: String) -> AdaptyUI.ProductInfo? {
        .init(
            id: id,
            title: properties["title"]?.asText,
            subtitle: properties["subtitle"]?.asText,
            subtitlePayAsYouGo: properties["subtitle_payasyougo"]?.asText,
            subtitlePayUpFront: properties["subtitle_payupfront"]?.asText,
            subtitleFreeTrial: properties["subtitle_freetrial"]?.asText,
            secondTitle: properties["second_title"]?.asText,
            secondSubitle: properties["second_subtitle"]?.asText,
            button: properties["button"]?.asButton,
            tagText: properties["tag_text"]?.asText,
            tagShape: properties["tag_shape"]?.asShape
        )
    }
}
