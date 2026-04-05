//
//  Versions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import AdaptyUIBuilder
import Foundation

extension Adapty {
    public nonisolated static let SDKVersion = "5.0.0-SNAPSHOT"
    nonisolated static let fallbackFormatVersion = 10
    nonisolated static let userAcquisitionVersion = 1

    nonisolated static let uiSchemaVersion = AdaptyUISchema.formatVersion
    nonisolated static let uiBuilderVersion = AdaptyUISchema.builderVersion
}

extension AdaptyOnboarding {
    nonisolated static let viewConfigurationVersion = "2.0.0"
}

