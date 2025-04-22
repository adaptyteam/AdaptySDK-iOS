//
//  AdaptyOnboarding.ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.04.2025.
//

import Foundation

package extension AdaptyOnboarding {
    struct ViewConfiguration: Sendable, Hashable {
        let responseLocale: AdaptyLocale
        package let url: URL
    }
}

extension AdaptyOnboarding.ViewConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case responseLocale = "lang"
        case url = "config_url"
    }
}
