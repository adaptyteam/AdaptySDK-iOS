//
//  Log+stamp.swift
//
//
//  Created by Aleksei Valiano on 22.08.2024
//
//

import Foundation

extension Log {
    @inlinable
    package nonisolated static var stamp: String {
        var result = ""
        let base62chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        for _ in 0 ..< 6 {
            result.append(base62chars[Int(arc4random_uniform(62))])
        }
        return result
    }
}
