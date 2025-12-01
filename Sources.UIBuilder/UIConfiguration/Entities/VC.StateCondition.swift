//
//  VC.StateCondition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    enum StateCondition: Sendable, Hashable {
        case selectedSection(id: String, index: Int)
        case selectedProduct(id: String, groupId: String)
    }
}
