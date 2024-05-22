//
//  LocalizedViewConfiguration.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    public struct LocalizedViewConfiguration {
        public let id: String
        public let locale: String
        public let isRightToLeft: Bool
        package let templateId: String
        package let screens: [String: Screen]
        package let templateRevision: Int64
    }
}

#if DEBUG
    package extension AdaptyUI.LocalizedViewConfiguration {
        static func create(
            id: String = UUID().uuidString,
            locale: String = AdaptyLocale.defaultPaywallLocale.id,
            isRightToLeft: Bool = false,
            templateId: String,
            screen: AdaptyUI.Screen,
            templateRevision: Int64 = 0
        ) -> Self {
            create(
                id: id,
                locale: locale,
                isRightToLeft: isRightToLeft,
                templateId: templateId,
                screens: ["default": screen],
                templateRevision: templateRevision
            )
        }

        static func create(
            id: String = UUID().uuidString,
            locale: String = AdaptyLocale.defaultPaywallLocale.id,
            isRightToLeft: Bool = false,
            templateId: String,
            screens: [String: AdaptyUI.Screen],
            templateRevision: Int64 = 0
        ) -> Self {
            .init(
                id: id,
                locale: locale,
                isRightToLeft: isRightToLeft,
                templateId: templateId,
                screens: screens,
                templateRevision: templateRevision
            )
        }
    }
#endif

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), templateRevision: \(templateRevision), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
