//
//  VCS.ScreenInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.01.2026.
//

import Foundation

package extension VS {
    struct ScreenInstance: Sendable, Hashable {
        let id: String
        let navigatorId: String
        let configuration: VC.Screen
        let contextPath: [String]
    }
}

