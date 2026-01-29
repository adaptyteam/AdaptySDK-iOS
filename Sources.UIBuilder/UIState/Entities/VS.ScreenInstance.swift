//
//  VCS.ScreenInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.01.2026.
//

import Foundation

package extension VS {
    struct ScreenInstance: Sendable, Hashable {
        package let id: String
        package let type: VC.ScreenType
        package let contextPath: [String]
    }
}
