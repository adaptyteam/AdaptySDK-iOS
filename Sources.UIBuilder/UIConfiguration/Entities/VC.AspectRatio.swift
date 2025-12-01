//
//  VC.AspectRatio.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    enum AspectRatio: Sendable, Hashable {
        case fit
        case fill
        case stretch
    }
}

extension VC.AspectRatio {
    static let `default`: Self = .fit
}
