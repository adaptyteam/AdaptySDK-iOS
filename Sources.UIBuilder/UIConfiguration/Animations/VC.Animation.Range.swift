//
//  VC.Animation.Range.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension VC.Animation {
    struct Range<T: Sendable & Equatable>: Sendable, Equatable {
        let start: T
        let end: T
    }
}
