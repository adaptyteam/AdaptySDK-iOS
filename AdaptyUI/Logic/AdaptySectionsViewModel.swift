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
    let logId: String

    package init(logId: String) {
        self.logId = logId
    }

    @Published var sectionsStates = [String: Int]()

    func updateSelection(for sectionId: String, index: Int) {
        sectionsStates[sectionId] = index
    }

    func selectedIndex(for sectionId: String) -> Int? {
        sectionsStates[sectionId]
    }

    func selectedIndex(for section: AdaptyUICore.Section) -> Int {
        if let stateIndex = sectionsStates[section.id] {
            return stateIndex
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.sectionsStates[section.id] = section.index
            }
            return section.index
        }
    }
}

#endif
