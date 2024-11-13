//
//  AdaptyPaywall+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import Adapty
import Foundation

extension AdaptyPaywall: AdaptyJsonDataRepresentable {
    @inlinable
    public var asAdaptyJsonData: Data {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
