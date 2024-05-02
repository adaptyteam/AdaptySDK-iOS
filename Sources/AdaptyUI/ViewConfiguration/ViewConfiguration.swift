//
//  ViewConfiguration.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    struct ViewConfiguration {
        let id: String
        /// An identifier for the template, used for ViewConfiguration creation.
        let templateId: String
        let version: Int64
        let assets: [String: Asset]
        let responseLocale: AdaptyLocale
        let localizations: [AdaptyLocale: Localization]
        let defaultLocalization: Localization?
        let screens: [String: Screen]
    }
}

extension AdaptyUI.ViewConfiguration: CustomStringConvertible {
    var description: String {
        "(id: \(id), templateId: \(templateId), version: \(version))"
    }
}

extension AdaptyUI.ViewConfiguration: Decodable {
    enum ContainerCodingKeys: String, CodingKey {
        case container = "paywall_builder_config"
        case responseLocale = "lang"
        case id = "paywall_builder_id"
    }

    enum CodingKeys: String, CodingKey {
        case format
        case templateId = "template_id"
        case version = "template_revision"
        case assets
        case localizations
        case defaultLocalization = "default_localization"
        case screens = "styles"
    }

    init(from decoder: Decoder) throws {
        let superContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        id = try superContainer.decode(String.self, forKey: .id)
        responseLocale = try superContainer.decode(AdaptyLocale.self, forKey: .responseLocale)
        let container = try superContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .container)

        let _ = try (container.decode(String.self, forKey: .format).split(separator: ".").first).flatMap { Int($0) } ?? 2

        templateId = try container.decode(String.self, forKey: .templateId)
        version = try container.decode(Int64.self, forKey: .version)

        assets = try (container.decodeIfPresent(AssetsContainer.self, forKey: .assets))?.value ?? [:]

        let localizationsArray = try container.decodeIfPresent([Localization].self, forKey: .localizations) ?? []
        let localizations = try [AdaptyLocale: Localization](localizationsArray.map { ($0.id, $0) }, uniquingKeysWith: { _, _ in
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.localizations], debugDescription: "Duplicate id"))
        })
        self.localizations = localizations
        if let defaultLocalization = try container.decodeIfPresent(AdaptyLocale.self, forKey: .defaultLocalization) {
            self.defaultLocalization = localizations[defaultLocalization]
        } else {
            defaultLocalization = nil
        }

        screens = try container.decode([String: Screen].self, forKey: .screens)
    }
}
