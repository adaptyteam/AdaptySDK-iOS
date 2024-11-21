//
//  AdaptyPluginEvent.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import Foundation

public protocol AdaptyPluginEvent: Encodable {
    var id: String { get }
}

public extension AdaptyPluginEvent {
    @inlinable
    var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
