//
//  VC.Action.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    struct Action: Sendable, Hashable {
        let function: String
        let params: [String: String]?
    }
}
