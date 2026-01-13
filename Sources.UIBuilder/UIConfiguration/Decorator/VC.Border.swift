//
//  VC.Border.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Border: Sendable, Hashable {
        package let filling: AssetReference
        package let thickness: Double
    }
}
