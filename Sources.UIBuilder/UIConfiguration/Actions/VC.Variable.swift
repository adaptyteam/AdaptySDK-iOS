//
//  VC.Variable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

package extension VC {
    struct Variable: Sendable, Hashable {
        let path: [String]
        let context: Context
    }
}
