//
//  PaywallConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct PaywallConfiguration {
        public let templateId: String
        let version: Int64
        let assets: [String: Asset]
        let localizations: [String: Localization]
        let defaultLocalization: Localization?
        let styles: [String: Style]
        public let isHard: Bool
        private let termsUrlId: String?
        private let privacyUrlId: String?
    }
}

extension AdaptyUI.PaywallConfiguration {
    public func string(id: String, locale: String) -> String? {
        localizations[locale]?.strings?[id] ?? defaultLocalization?.strings?[id]
    }

    func asset(id: String, locale: String) -> AdaptyUI.Asset? {
        localizations[locale]?.assets?[id] ?? defaultLocalization?.assets?[id] ?? assets[id]
    }

    public func termsUrl(locale: String) -> String? {
        guard let id = termsUrlId else { return nil }
        return string(id: id, locale: locale)
    }

    public func privacyUrl(locale: String) -> String? {
        guard let id = privacyUrlId else { return nil }
        return string(id: id, locale: locale)
    }
}

extension AdaptyUI.PaywallConfiguration: Decodable {
    enum ContainerCodingKeys: String, CodingKey {
        case container = "paywall_builder_config"
    }

    enum CodingKeys: String, CodingKey {
        case format
        case templateId = "template_id"
        case version = "template_revision"
        case terms
        case privacy
        case assets
        case localizations
        case defaultLocalization = "default_localization"
        case isHard = "is_hard_paywall"
        case styles
    }

    enum TermsCodingKeys: String, CodingKey {
        case url
    }

    public init(from decoder: Decoder) throws {
        let superContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let container = try superContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .container)

        _ = try container.decode(String.self, forKey: .format) // TODO: "1.0.0"
        templateId = try container.decode(String.self, forKey: .templateId)
        version = try container.decode(Int64.self, forKey: .version)

        isHard = try container.decodeIfPresent(Bool.self, forKey: .isHard) ?? false

        assets = (try container.decodeIfPresent(AdaptyUI.Assets.self, forKey: .assets))?.value ?? [:]

        let localizationsArray = try container.decode([AdaptyUI.Localization].self, forKey: .localizations)
        let localizations = Dictionary(uniqueKeysWithValues: localizationsArray.map { ($0.id, $0) })
        self.localizations = localizations
        if let defaultLocalization = try container.decodeIfPresent(String.self, forKey: .defaultLocalization) {
            self.defaultLocalization = localizations[defaultLocalization]
        } else {
            defaultLocalization = nil
        }

        styles = try container.decode([String:AdaptyUI.Style].self, forKey: .styles)

        termsUrlId = try container.nestedContainer(keyedBy: TermsCodingKeys.self, forKey: .terms).decodeIfPresent(String.self, forKey: .url)

        privacyUrlId = try container.nestedContainer(keyedBy: TermsCodingKeys.self, forKey: .privacy).decodeIfPresent(String.self, forKey: .url)
    }
}
