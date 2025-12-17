//
//  VC.Animation.BorderParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension VC.Animation {
    struct BorderParameters: Sendable, Hashable {
        package let color: Range<VC.Mode<VC.Filling>>?
        package let thickness: Range<Double>?
    }
}
