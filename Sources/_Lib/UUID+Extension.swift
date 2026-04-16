//
//  UUID+Extension.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.03.2026.
//

import Foundation

extension UUID {
    @inlinable
    var lowercased: String {
        uuidString.lowercased()
    }
}
