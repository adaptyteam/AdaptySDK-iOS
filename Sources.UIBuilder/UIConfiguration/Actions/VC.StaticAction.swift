//
//  VC.StaticAction.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.09.2026.
//

import Foundation

package extension VC {
    struct StaticAction: Sendable {
        let path: [String]
    }
}

extension VC.StaticAction {
    var isSDK: Bool {
        path.first == "SDK"
    }
}
