//
//  AdaptyUIBuilder+WebPresentation.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 06.05.2026.
//

#if canImport(UIKit)

import Foundation

extension VC.WebOpenInParameter {
    var toWebPresentation: AdaptyUIBuilder.WebPresentation {
        switch self {
        case .browserOutApp: .externalBrowser
        case .browserInApp: .inAppBrowser
        }
    }
}

#endif
