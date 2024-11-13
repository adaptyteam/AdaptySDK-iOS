//
//  AdaptyScreensViewModel.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyScreensViewModel: ObservableObject {
    struct BottomSheet: Identifiable {
        var id: String
        var bottomSheet: VC.BottomSheet
    }

    let logId: String
    let eventsHandler: AdaptyEventsHandler
    let viewConfiguration: AdaptyViewConfiguration

    package init(
        eventsHandler: AdaptyEventsHandler,
        viewConfiguration: AdaptyViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        self.logId = eventsHandler.logId
        self.viewConfiguration = viewConfiguration
    }

    @Published var presentedScreensStack = [BottomSheet]()

    func presentScreen(id: String) {
        Log.ui.verbose("#\(logId)# presentScreen \(id)")

        if presentedScreensStack.contains(where: { $0.id == id }) {
            Log.ui.warn("#\(logId)# presentScreen \(id) Already Presented!")
            return
        }

        guard let bottomSheet = viewConfiguration.bottomSheets[id] else {
            Log.ui.warn("#\(logId)# presentScreen \(id) Not Found!")
            return
        }

        presentedScreensStack.append(.init(id: id, bottomSheet: bottomSheet))
    }

    func dismissScreen(id: String) {
        Log.ui.verbose("#\(logId)# dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0.id == id })
    }

    func dismissTopScreen() {
        guard let topScreenId = presentedScreensStack.last?.id else { return }

        dismissScreen(id: topScreenId)
    }
}

#endif
