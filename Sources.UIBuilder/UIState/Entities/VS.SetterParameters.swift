//
//  VS.SetterParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

extension VS {
    struct SetterParameters<T: JSValueConvertable>: Sendable, Hashable {
        let screenInstance: ScreenInstance
        let name: String
        let value: T
    }
}
