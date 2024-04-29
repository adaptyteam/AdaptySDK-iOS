//
//  Versions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import Foundation

extension Adapty {
    public static let SDKVersion = "2.10.4"

    public static func setCrossPlatformSDK(version: String, name: String) {
        Environment.CrossPlatformSDK.name = name
        Environment.CrossPlatformSDK.version = version
    }
}

extension Environment {
    enum CrossPlatformSDK {
        static var name: String?
        static var version: String?
    }
}
