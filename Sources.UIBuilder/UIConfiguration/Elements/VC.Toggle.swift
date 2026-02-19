//
//  VC.Toggle.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension VC {
    struct Toggle: Sendable, Hashable {
        package let value: Variable
        package let color: AssetReference?
    }
}
