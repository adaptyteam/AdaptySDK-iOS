//
//  VC.Element.Overlay.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC.Element {
    struct Overlay: Hashable {
        let horizontalAlignment: VC.HorizontalAlignment
        let verticalAlignment: VC.VerticalAlignment
        let content: VC.Element
    }
}
