//
//  Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension Adapty {
    public struct Configuration: Sendable {
        static let `default` = (
            observerMode: false,
            idfaCollectionDisabled: false,
            ipAddressCollectionDisabled: false,
            backend: Backend.URLs.publicEnvironment
        )

        let apiKey: String
        let customerUserId: String?
        let observerMode: Bool
        let idfaCollectionDisabled: Bool
        let ipAddressCollectionDisabled: Bool
        let backend: Backend.URLs
        let logLevel: AdaptyLog.Level?
        let crossPlatformSDK: (name: String, version: String)?
    }
}


