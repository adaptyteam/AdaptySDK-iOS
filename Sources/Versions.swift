//
//  Versions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import Foundation

extension Adapty {
    public static let SDKVersion = "3.0.0-SNAPSHOT"
    static let fallbackFormatVersion = 6

    public static func setCrossPlatformSDK(version: String, name: String) {
        Environment.CrossPlatformSDK.name = name
        Environment.CrossPlatformSDK.version = version
    }
}

extension AdaptyUI {
    static let configurationFormatVersion = "4.0.0"
    static let builderVersion = "4_0"
}

extension Environment {
    enum CrossPlatformSDK {
        static var name: String?
        static var version: String?
    }
}
