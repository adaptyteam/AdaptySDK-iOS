//
//  VC.Box.Length.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension VC.Box {
    enum Length: Sendable {
        case fixed(VC.Unit)
        case flexible(min: VC.Unit?, max: VC.Unit?)
        case shrinkable(min: VC.Unit, max: VC.Unit?)
        case fillMax
    }
}
