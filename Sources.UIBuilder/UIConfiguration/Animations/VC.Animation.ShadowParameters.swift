//
//  VC.Animation.ShadowParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension VC.Animation {
    struct ShadowParameters: Sendable, Equatable {
        let color: Range<VC.AssetReference>?
        let blurRadius: Range<Double>?
        let offset: Range<VC.Offset>?
    }
}
