//
//  VC.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Button: Sendable, Hashable {
        package let actions: [Action]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
package extension VC.Button {
    static func create(
        actions: [VC.Action],
        normalState: VC.Element,
        selectedState: VC.Element? = nil,
        selectedCondition: VC.StateCondition? = nil
    ) -> Self {
        .init(
            actions: actions,
            normalState: normalState,
            selectedState: selectedState,
            selectedCondition: selectedCondition
        )
    }
}
#endif
