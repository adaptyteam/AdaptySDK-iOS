//
//  VC.Decorator.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

extension VC.Decorator {
    struct Shadow: Sendable {
        let id: Int?
        let kind: Kind
        let filling: VC.AssetReference
        let blurRadius: Double
        let offset: VC.Offset
    }
}
