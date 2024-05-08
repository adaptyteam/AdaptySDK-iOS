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
        let version: Int64
    }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), isRightToLeft: \(isRightToLeft), version: \(version))"
    }
}
