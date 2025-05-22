//
//  Log+stamp.swift
//
//
//  Created by Aleksei Valiano on 22.08.2024
//
//

import Foundation

package extension Log {
    fileprivate static let stampChars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

    static var stamp: String {
        var result = ""
        for _ in 0 ..< 6 {
            result.append(Log.stampChars[Int(arc4random_uniform(62))])
        }
        return result
    }

    static func stamp(parent: String) -> String {
        "\(parent)/\(stamp)"
    }
}

package extension Hashable {
    var stamp: String {
        let hashValue = self.hashValue
        var value = hashValue >= 0 ? hashValue : -hashValue
        var result = ""
        for i in 0 ..< 10 {
            if i == 5 { result.append("_") }
            result.append(Log.stampChars[value % 62])
            value /= 62
        }
        return result
    }
}
