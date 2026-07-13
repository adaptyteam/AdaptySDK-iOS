//
//  AnyOptional.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 12.04.2026.
//

import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        self == nil
    }
}

extension NSNull: AnyOptional {
    var isNil: Bool {
        true
    }
}

public func isNil(_ value: Any) -> Bool {
    if let optional = value as? AnyOptional, optional.isNil {
        true
    } else {
        false
    }
}

