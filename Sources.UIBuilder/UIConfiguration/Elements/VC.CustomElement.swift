//
//  VC.CustomElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.08.2026.
//

import Foundation

extension VC {
    struct CustomElement: Sendable, Identifiable {
        let id: String
        let type: String
        let data: Data?
    }
}
