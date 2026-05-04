//
//  VC.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

extension VC {
    struct Shadow: Sendable, Hashable {
        let filling: AssetReference
        let blurRadius: Double
        let offset: Offset
    }
}
