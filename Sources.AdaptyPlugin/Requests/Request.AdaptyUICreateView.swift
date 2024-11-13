//
//  Request.AdaptyUICreateView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUICreateView: AdaptyPluginRequest {
        static let method = Method.adaptyUICreateView

        let paywall: AdaptyPaywall
        let locale: String
        let preloadProducts: Bool
        let customTags: [String: String]

        enum CodingKeys: String, CodingKey {
            case paywall
            case locale
            case preloadProducts = "preload_products"
            case customTags = "custom_tags"
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                paywall: params.value(forKey: CodingKeys.paywall),
                locale: params.value(String.self, forKey: CodingKeys.locale),
                preloadProducts: params.value(Bool.self, forKey: CodingKeys.preloadProducts),
                customTags: params.valueIfPresent(forKey: CodingKeys.preloadProducts)
            )
        }

        init(
            paywall: KeyValue,
            locale: String,
            preloadProducts: Bool,
            customTags: KeyValue?
        ) throws {
            self.paywall = try paywall.decode(AdaptyPaywall.self)
            self.locale = locale
            self.preloadProducts = preloadProducts
            self.customTags = try customTags?.decode([String: String].self) ?? [:]
        }

        func execute() async throws -> AdaptyJsonData {
            
            // TODO: implement
            // use paywall, locale, preloadProducts, customTags
            let view = AdaptyUI.View(
                id: "id",
                templateId: "templateId",
                paywallId: "paywallId",
                paywallVariationId: "paywallVariationId"
            )
            return .success(view)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUICreateView(
        paywall: String,
        locale: String,
        preloadProducts: Bool,
        customTags: String?,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUICreateView.CodingKeys
        execute(with: completion) { try Request.AdaptyUICreateView(
            paywall: KeyValue(key: CodingKeys.paywall, value: paywall),
            locale: locale,
            preloadProducts: preloadProducts,
            customTags: customTags.map { KeyValue(key: CodingKeys.customTags, value: $0) }
        ) }
    }
}
