//
//  AdaptyPaywall+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import Adapty
import Foundation

public extension AdaptyPaywall {
    @inlinable
    var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
