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
        eventsHandler.log(.verbose, "presentScreen \(id)")

        if presentedScreensStack.contains(where: { $0.id == id }) {
            eventsHandler.log(.warn, "presentScreen \(id) Already Presented!")
            return
        }

        guard let bottomSheet = viewConfiguration.bottomSheets[id] else {
            eventsHandler.log(.warn, "presentScreen \(id) Not Found!")
            return
        }

        presentedScreensStack.append(.init(id: id, bottomSheet: bottomSheet))
    }

    func dismissScreen(id: String) {
        eventsHandler.log(.verbose, "dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0.id == id })
    }

    func dismissTopScreen() {
        guard let topScreenId = presentedScreensStack.last?.id else { return }

        dismissScreen(id: topScreenId)
    }
}

#endif
