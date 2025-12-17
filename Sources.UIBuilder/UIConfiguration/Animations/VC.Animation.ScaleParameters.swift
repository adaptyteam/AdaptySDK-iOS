//
//  VC.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension VC.Animation {
    struct ScaleParameters: Sendable, Hashable {
        package let scale: Range<VC.Point>
        package let anchor: VC.Point
    }
}
