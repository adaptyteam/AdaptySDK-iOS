//
//  LocalizedViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    public struct LocalizedViewConfiguration {
        public let id: String
        public let templateId: String
        public let locale: String
        public let styles: [String: OldViewStyle]

        public let isHard: Bool
        public let mainImageRelativeHeight: Double?

        let version: Int64
    }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), version: \(version), isHard: \(isHard))"
    }
}
