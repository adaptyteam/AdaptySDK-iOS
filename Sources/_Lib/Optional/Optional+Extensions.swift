//
//  Optional+Extensions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import Foundation

extension Optional where Wrapped: Equatable {
    func nonOptionalIsEqual(_ other: Wrapped?) -> Bool {
        guard case let .some(wrapped) = self, let other else {
            return false
        }
        return wrapped == other
    }
}
