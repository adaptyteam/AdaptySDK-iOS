//
//  AdaptyUISectionsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUISectionsViewModel: ObservableObject {
    private let logId: String

    package init(logId: String) {
        self.logId = logId
    }

    @Published var sectionsStates = [String: Int32]()

    func updateSelection(for sectionId: String, index: Int32) {
        sectionsStates[sectionId] = index
    }

    func selectedIndex(for sectionId: String) -> Int32? {
        sectionsStates[sectionId]
    }

    func selectedIndex(for section: VC.Section) -> Int32 {
        if let stateIndex = sectionsStates[section.id] {
            return stateIndex
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.sectionsStates[section.id] = section.index
            }
            return section.index
        }
    }

    package func resetSectionsState() {
        Log.ui.verbose("#\(logId)# resetSectionsState")
        sectionsStates.removeAll()
    }
}

#endif
