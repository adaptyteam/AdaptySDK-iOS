//
//  VC.Animation.BorderParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension VC.Animation {
    struct BorderParameters: Sendable, Equatable {
        let color: Range<VC.AssetReference>?
        let thickness: Range<Double>?
    }
}
