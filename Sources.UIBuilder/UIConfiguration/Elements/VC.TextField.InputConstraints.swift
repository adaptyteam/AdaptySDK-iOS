
//
//  VC.TextField.InputConstraints.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC.TextField {
    struct InputConstraints: Hashable {
        let regex: String?
        let maxLength: Int?
    }
}
