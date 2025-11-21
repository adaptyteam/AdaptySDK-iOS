//
//  Versions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.08.2022.
//

import Foundation
import AdaptyUIBuilder

extension Adapty {
    public nonisolated static let SDKVersion = "3.14.0"
    nonisolated static let fallbackFormatVersion = 9
    nonisolated static let userAcquisitionVersion = 1
    
    nonisolated static let uiSchemaVersion = AdaptyUISchema.formatVersion
    nonisolated static let uiBuilderVersion = AdaptyUISchema.builderVersion


}

extension AdaptyOnboarding.ViewConfiguration {
    nonisolated static let uiVersion = "2.0.0"
}


