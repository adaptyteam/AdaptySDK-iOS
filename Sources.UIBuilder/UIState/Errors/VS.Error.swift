//
//  VS.Error.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation

extension VS {
    enum Error: Swift.Error {
        case jsFunctionNotFound(String)
        case jsVariableNotFound(String)
    }
}
