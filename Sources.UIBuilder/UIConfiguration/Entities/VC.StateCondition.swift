//
//  VC.StateCondition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

// TODO: Deprecated
package extension VC {
    enum StateCondition: Sendable, Hashable {
        case selectedSection(id: String, index: Int32)
        case selectedProduct(id: String, groupId: String)
    }
}

