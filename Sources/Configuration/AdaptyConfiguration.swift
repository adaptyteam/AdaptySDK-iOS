//
//  AdaptyConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

public struct AdaptyConfiguration: Sendable {
    static let `default` = (
        observerMode: false,
        idfaCollectionDisabled: false,
        ipAddressCollectionDisabled: false,
        backend: Backend.URLs.defaultPublicEnvironment
    )

    let apiKey: String
    let customerUserId: String?
    let appAccountToken: UUID?
    let observerMode: Bool
    let idfaCollectionDisabled: Bool
    let ipAddressCollectionDisabled: Bool
    let callbackDispatchQueue: DispatchQueue?
    let backend: Backend.URLs
    let logLevel: AdaptyLog.Level?
    let crossPlatformSDK: (name: String, version: String)?
}
