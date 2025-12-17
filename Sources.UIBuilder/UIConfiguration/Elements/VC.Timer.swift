//
//  VC.Timer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension VC {
    struct Timer: Sendable, Hashable {
        package let id: String
        package let state: State
        package let format: [Item]
        package let actions: [Action]
        package let horizontalAlign: VC.HorizontalAlignment

        init(id: String, state: State, format: [Item], actions: [Action], horizontalAlign: VC.HorizontalAlignment) {
            self.id = id
            self.state = state
            self.format = format.sorted(by: { $0.from > $1.from }) //TODO: move on parsing
            self.actions = actions
            self.horizontalAlign = horizontalAlign
        }
    }
}

package extension VC.Timer {
    func format(byValue: TimeInterval) -> VC.RichText {
        let index =
            if let index = format.firstIndex(where: { byValue > $0.from }) {
                index > 0 ? index - 1 : index
            } else {
                format.count - 1
            }
        guard format.indices.contains(index) else { return .empty }
        return format[index].value
    }
}
