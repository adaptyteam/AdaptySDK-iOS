//
//  AdaptySectionsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptySectionsViewModel: ObservableObject {
    private var logId: String { eventsHandler.logId }
    private let eventsHandler: AdaptyEventsHandler

    package init(eventsHandler: AdaptyEventsHandler) {
        self.eventsHandler = eventsHandler
    }

    @Published var sectionsStates = [String: Int]()

    func updateSelection(for sectionId: String, index: Int) {
        sectionsStates[sectionId] = index
    }

    func selectedIndex(for sectionId: String) -> Int? {
        sectionsStates[sectionId]
    }

    func selectedIndex(for section: VC.Section) -> Int {
        if let stateIndex = sectionsStates[section.id] {
            return stateIndex
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.sectionsStates[section.id] = section.index
            }
            return section.index
        }
    }
    
    func resetSectionsState() {
        Log.ui.verbose("#\(logId)# resetSectionsState")
        sectionsStates.removeAll()
    }
}

#endif
