//
//  AdaptySectionsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
package class AdaptySectionsViewModel: ObservableObject {
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
    
    func selectedIndex(for section: AdaptyUI.Section) -> Int {
        if let stateIndex = sectionsStates[section.id] {
            return stateIndex
        } else {
            sectionsStates[section.id] = section.index
            return section.index
        }
    }
}

#endif
