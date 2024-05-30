//
//  VC.If.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct If: Decodable {
        let content: AdaptyUI.ViewConfiguration.Element

        enum CodingKeys: String, CodingKey {
            case platform
            case version
            case then
            case `else`
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            content = if
                try container.decodeIfPresent(String.self, forKey: .platform).map({ $0 == "ios" }) ?? true,
                try container.decodeIfPresent(String.self, forKey: .version).map(checkVersionFormat) ?? true {
                try container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .then)
            } else {
                try container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .else)
            }

            func checkVersionFormat(version _: String) -> Bool { true }
        }
    }
}
