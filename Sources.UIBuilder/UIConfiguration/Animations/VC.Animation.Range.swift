//
//  VC.Animation.Range.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension VC.Animation {
    struct Range<T>: Sendable, Hashable where T: Sendable, T: Hashable {
        package let start: T
        package let end: T
    }
}
