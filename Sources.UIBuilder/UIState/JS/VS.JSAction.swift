//
//  JSAction.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct JSAction {
        let callback: JSValue
    }
}

extension VS.JSAction {
    init? (from value: Any?) {
        guard let callback = value as? JSValue, callback.isObject else {
            return nil
        }
        self.callback = callback
    }
}

