//
//  Environment+StoreKit2.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2023
//

import Foundation

extension Environment {
    enum StoreKit2 {
        static var available: Bool {
            if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
                return true
            } else {
                return false
            }
        }
    }
}
