//
//  AdaptyUI+StyleExtractor.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import Foundation

extension AdaptyUI.LocalizedViewConfiguration {
    func extractStyle(_ id: String) throws -> AdaptyUI.OldViewStyle {
        guard let style = styles[id] else {
            throw AdaptyUIError.styleNotFound(id)
        }
        return style
    }
    
    func extractDefaultStyle() throws -> AdaptyUI.OldViewStyle {
        try extractStyle("default")
    }
}
