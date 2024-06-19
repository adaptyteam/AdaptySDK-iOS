//
//  AdaptyScreensViewModel.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
package class AdaptyScreensViewModel: ObservableObject {
    struct BottomSheet: Identifiable {
        var id: String
        var bottomSheet: AdaptyUI.BottomSheet
    }
    
    let eventsHandler: AdaptyEventsHandler
    let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    package init(
        eventsHandler: AdaptyEventsHandler,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        self.viewConfiguration = viewConfiguration
    }

    @Published var presentedScreensStack = [BottomSheet]()

    func presentScreen(id: String) {
        // TODO: check unique id
        eventsHandler.log(.verbose, "presentScreen \(id)")
        
        guard let bottomSheet = viewConfiguration.bottomSheets[id] else {
            // TODO: Warning
            return
        }
        
        presentedScreensStack.append(.init(id: id, bottomSheet: bottomSheet))
    }

    func dismissScreen(id: String) {
        eventsHandler.log(.verbose, "dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0.id == id })
    }
}

#endif
