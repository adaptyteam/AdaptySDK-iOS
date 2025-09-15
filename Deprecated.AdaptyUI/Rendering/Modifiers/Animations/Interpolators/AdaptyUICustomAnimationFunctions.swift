//
//  AdaptyUICustomAnimationFunctions.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/21/25.
//

import Foundation

enum AdaptyUICustomAnimationFunctions {
    static func easeInElastic(_ x: Double) -> Double {
        let c4 = (2 * Double.pi) / 3
        return x == 0
            ? 0
            : x == 1
            ? 1
            : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)
    }

    static func easeOutElastic(_ x: Double) -> Double {
        let c4 = (2 * Double.pi) / 3
        return x == 0
            ? 0
            : x == 1
            ? 1
            : pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1
    }

    static func easeInOutElastic(_ x: Double) -> Double {
        let c5 = (2 * Double.pi) / 4.5
        return x == 0
            ? 0
            : x == 1
            ? 1
            : x < 0.5
            ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
            : (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
    }

    static func easeInBounce(_ x: Double) -> Double {
        return 1 - easeOutBounce(1 - x)
    }

    static func easeOutBounce(_ x: Double) -> Double {
        let n1 = 7.5625
        let d1 = 2.75

        if x < 1 / d1 {
            return n1 * x * x
        } else if x < 2 / d1 {
            let x = x - 1.5 / d1
            return n1 * x * x + 0.75
        } else if x < 2.5 / d1 {
            let x = x - 2.25 / d1
            return n1 * x * x + 0.9375
        } else {
            let x = x - 2.625 / d1
            return n1 * x * x + 0.984375
        }
    }

    static func easeInOutBounce(_ x: Double) -> Double {
        return x < 0.5
            ? (1 - easeOutBounce(1 - 2 * x)) / 2
            : (1 + easeOutBounce(2 * x - 1)) / 2
    }
}
