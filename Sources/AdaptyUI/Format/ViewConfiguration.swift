//
//  ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct ViewConfiguration {
        public let id: String
        public let templateId: String
        let version: Int64
        let assets: [String: Asset]
        let localizations: [String: Localization]
        let defaultLocalization: Localization?
        let styles: [String: ViewStyle]
        let isHard: Bool
        let termsUrlId: String
        let privacyUrlId: String
    }
}

extension AdaptyUI.ViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), version: \(version), isHard: \(isHard))"
    }
}

extension AdaptyUI.ViewConfiguration: Decodable {
    enum ContainerCodingKeys: String, CodingKey {
        case container = "paywall_builder_config"
        case id = "paywall_builder_id"
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
        id = try superContainer.decode(String.self, forKey: .id)
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

        styles = try container.decode([String: AdaptyUI.ViewStyle].self, forKey: .styles)

        termsUrlId = try container.nestedContainer(keyedBy: TermsCodingKeys.self, forKey: .terms).decode(String.self, forKey: .url)

        privacyUrlId = try container.nestedContainer(keyedBy: TermsCodingKeys.self, forKey: .privacy).decode(String.self, forKey: .url)
    }
}
