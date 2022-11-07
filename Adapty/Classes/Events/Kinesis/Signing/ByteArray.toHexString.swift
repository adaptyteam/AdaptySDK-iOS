//
//  ByteArray.toHexString.swift
//  Adapty
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import Foundation

extension Array where Element == UInt8 {
    func toHexString() -> String {
        lazy.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}
