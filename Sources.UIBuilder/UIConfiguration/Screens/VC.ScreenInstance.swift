//
//  VC.ScreenInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.01.2026.
//

import Foundation

package extension VC {
    struct ScreenInstance: Sendable, Hashable {
        let id: String
        let type: VC.ScreenType
        let contextPath: [String]
    }
}
