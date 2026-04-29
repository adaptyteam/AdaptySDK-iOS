//
//  VC.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension VC.Animation {
    struct BoxParameters: Sendable, Equatable {
        let width: Range<VC.Unit>?
        let height: Range<VC.Unit>?
    }
}
