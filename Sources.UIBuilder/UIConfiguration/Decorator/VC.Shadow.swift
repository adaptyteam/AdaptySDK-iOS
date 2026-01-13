//
//  VC.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2025
//

import Foundation

package extension VC {
    struct Shadow: Sendable, Hashable {
        package let filling: AssetReference
        package let blurRadius: Double
        package let offset: Offset
    }
}
