//
//  AdaptyUIActionsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
package final class AdaptyUIActionsViewModel: ObservableObject {
    private let logId: String
    private let logic: AdaptyUIBuilderLogic

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic
    ) {
        self.logId = logId
        self.logic = logic
    }

    func closeActionOccurred() {
        logic.reportDidPerformAction(.close)
    }
    
    func openUrlActionOccurred(url urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            Log.ui.warn("#\(logId)# can't parse url: \(urlString ?? "null")")
            return
        }
        logic.reportDidPerformAction(.openURL(url: url))
    }
    
    func customActionOccurred(id: String) {
        logic.reportDidPerformAction(.custom(id: id))
    }
}

#endif
